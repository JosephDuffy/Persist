import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol UserDefaultsMacro: AccessorMacro, PeerMacro {}

enum BaseType {
    indirect case optional(BaseType)
    case identifier(IdentifierTypeSyntax)
    case array(ArrayTypeSyntax)
    case dictionary(DictionaryTypeSyntax)

    var isOptional: Bool {
        switch self {
        case .optional:
            return true
        case .identifier, .array, .dictionary:
            return false
        }
    }

    var rootNonOptionalType: TypeSyntaxProtocol {
        switch self {
        case .optional(let baseType):
            baseType.rootNonOptionalType
        case .identifier(let identifierTypeSyntax):
            identifierTypeSyntax
        case .array(let arrayTypeSyntax):
            arrayTypeSyntax
        case .dictionary(let dictionaryTypeSyntax):
            dictionaryTypeSyntax
        }
    }
}

extension UserDefaultsMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        isMutating: Bool,
        isThrowing: Bool,
        transformerModifier: TransformerModifier?
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.accessorBlock == nil
        else {
            throw HashableMacroDiagnosticMessage(
                id: "incompatible-property",
                message: "Generic property is not supported error.",
                severity: .error
            )
        }

        guard let typeAnnotation = binding.typeAnnotation else {
            throw HashableMacroDiagnosticMessage(
                id: "property-requires-type-annotation",
                message: "@Persist does not support properties without an explicit type annotation.",
                severity: .error
            )
        }

        func unwrapBaseType(_ type: TypeSyntax) -> BaseType? {
            if let optionalType = type.as(OptionalTypeSyntax.self) {
                if let wrappedType = unwrapBaseType(optionalType.wrappedType) {
                    return .optional(wrappedType)
                } else {
                    return nil
                }
            } else if let identifier = type.as(IdentifierTypeSyntax.self) {
                return .identifier(identifier)
            } else if let dictionary = type.as(DictionaryTypeSyntax.self) {
                return .dictionary(dictionary)
            } else if let array = type.as(ArrayTypeSyntax.self) {
                // TODO: Check for things like [Int8], which are not supported.
                return .array(array)
            } else {
                return nil
            }
        }

        guard let baseType = unwrapBaseType(typeAnnotation.type) else {
            throw HashableMacroDiagnosticMessage(
                id: "unsupported-type-annotation",
                message: "@Persist does not support this type annotation.",
                severity: .error
            )
        }
        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var keyExpression: ExprSyntax?
        var transformerExpression: ExprSyntax?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                keyExpression = argument.expression
            case "transformer":
                transformerExpression = argument.expression
            default:
                break
            }
        }

        lazy var transformer: String? = if let keyPath = transformerExpression?.as(KeyPathExprSyntax.self) {
            keyPath
                .components
                .compactMap { component in
                    component
                        .component
                        .as(KeyPathPropertyComponentSyntax.self)?
                        .declName
                        .baseName
                        .trimmed
                        .text
                }
                .joined(separator: ".")
        } else if transformerExpression != nil {
            "\(identifier)_transformer"
        } else {
            nil
        }

        guard let keyExpression else {
            throw HashableMacroDiagnosticMessage(
                id: "missing-key-parameter",
                message: "The 'key' parameter must be provided.",
                severity: .error
            )
        }

        let userDefaultsPropertyName = try userDefaultsAccessor(labeledArguments: labeledArguments)


        let valueSetter = """
        \(userDefaultsPropertyName).set(newValue, forKey: \(keyExpression))
        """

        func valueAccessor(forBaseType baseType: BaseType) throws -> String {
            switch baseType {
            case .optional(let baseType):
                try valueAccessor(forBaseType: baseType)
            case .identifier(let identifierTypeSyntax):
                switch identifierTypeSyntax.name.trimmed.text {
                case "Bool", "Int", "UInt", "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64", "Float", "Double", "String", "Data", "Date", "CGFloat", "NSNumber":
                    """
                    if let value = \(userDefaultsPropertyName).object(forKey: \(keyExpression)) as? \(identifierTypeSyntax.name.trimmed) {
                            return value
                    }
                    """
                case "URL", "NSURL":
                    // URLs are actually stored as Data. We must use url(forKey:) to decode it.
                    """
                    // The stored object must be data. This is how URLs are stored by user defaults and it
                    // prevents user defaults from trying to coerce e.g. a string to a URL by assuming that
                    // it uses the 'file' protocol.
                    if \(userDefaultsPropertyName).object(forKey: \(keyExpression)) is Data, let value = \(userDefaultsPropertyName).url(forKey: \(keyExpression)) {
                            return value
                    }
                    """
                default:
                    throw HashableMacroDiagnosticMessage(
                        id: "unsupported-type",
                        message: "The '\(identifierTypeSyntax.name.trimmed.text)' type is not supported. If it is a typealias provide the original type.",
                        severity: .error
                    )
                }
            case .array(let arrayTypeSyntax):
                """
                if let value = \(userDefaultsPropertyName).object(forKey: \(keyExpression)) as? \(arrayTypeSyntax) {
                        return value
                }
                """
            case .dictionary(let dictionaryTypeSyntax):
                """
                if let value = \(userDefaultsPropertyName).object(forKey: \(keyExpression)) as? \(dictionaryTypeSyntax) {
                        return value
                }
                """
            }
        }

        var valueAccessor: String = try valueAccessor(forBaseType: baseType)

        if baseType.isOptional {
            valueAccessor += """
            
            return nil
            """
        } else if let defaultValue = binding.initializer?.value {
            valueAccessor += """
            
            return \(defaultValue)
            """
        } else {
            throw HashableMacroDiagnosticMessage(
                id: "non-optional-unsupported",
                message: "Non-optionals properties must have a default value.",
                severity: .error
            )
        }

        return [
            """
            get {
                \(raw: valueAccessor)
            }
            set {
                \(raw: valueSetter)
            }
            """
        ]
    }

    static func userDefaultsAccessor(labeledArguments: LabeledExprListSyntax) throws -> String {
        guard
            let userDefaultsExpression = labeledArguments.first(where: { argument in
                argument.label?.trimmed.text == "userDefaults"
            })?.expression
        else {
            throw HashableMacroDiagnosticMessage(
                id: "user-defaults-parameter-not-provided",
                message: "userDefaults parameter must be provided.",
                severity: .error
            )
        }

        if let keyPathExpression = userDefaultsExpression.as(KeyPathExprSyntax.self) {
            return keyPathExpression
                .components
                .compactMap {
                    $0
                        .component
                        .as(KeyPathPropertyComponentSyntax.self)?
                        .declName
                        .baseName
                        .trimmed
                        .text
                }
                .joined(separator: ".")
        } else if let memberAccessExpression = userDefaultsExpression.as(MemberAccessExprSyntax.self) {
            let base = memberAccessExpression.base?.trimmed.description ?? "UserDefaults"
            return "\(base).\(memberAccessExpression.declName.trimmed)"
        } else {
            throw HashableMacroDiagnosticMessage(
                id: "invalid-user-defaults-parameter",
                message: "userDefaults parameter must be a key path or a reference to a UserDefaults instance.",
                severity: .error
            )
        }
    }

    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        isMutating: Bool
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw HashableMacroDiagnosticMessage(
                id: "not-variable",
                message: "@Persist must be attached to a variable.",
                severity: .error
            )
        }

        return []

        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var keyExpression: ExprSyntax!
        var transformerExpression: ExprSyntax?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                keyExpression = argument.expression
            case "transformer":
                transformerExpression = argument.expression
            default:
                break
            }
        }

        guard let typeAnnotation = variable.bindings.first?.typeAnnotation else {
            throw HashableMacroDiagnosticMessage(
                id: "Can't identify type",
                message: "An explicit type is required.",
                severity: .error
            )
        }

        let inferredType = typeAnnotation.type.trimmed

        let identifier = variable.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.trimmed
        var declarations: [DeclSyntax] = []

        let userDefaultsPropertyName = try userDefaultsAccessor(labeledArguments: labeledArguments)

        if typeAnnotation.is(OptionalTypeSyntax.self) {
            declarations.append(
                """
                var $\(identifier): UserDefaultsObserver<\(inferredType)> {
                    return UpdateListenerWrapper<\(inferredType)>(
                        valuesStreamProvider: { @Sendable () -> AsyncStream<\(inferredType)> in
                            AsyncStream { continuation in
                                let observer = KeyPathObserver(updateListener: { newValue in
                                    if let newValue = newValue as? Value {
                                        continuation.yield(newValue)
                                    } else {
                                        continuation.yield(nil)
                                    }
                                })
                                \(raw: userDefaultsPropertyName).addObserver(observer, forKeyPath: \(keyExpression), options: .new, context: nil)
                                continuation.onTermination = { @Sendable _ in
                                    \(raw: userDefaultsPropertyName).removeObserver(observer, forKeyPath: \(keyExpression))
                                }
                            }
                            return self.\(identifier)_storage.valuesStream(forKey: \(keyExpression))
                        }
                    )
                }
                """
            )
        } else {
            if let defaultValue = variable.bindings.first!.initializer?.value {
                declarations.append(
                    """
                    var $\(identifier): UpdateListenerWrapper<\(inferredType)> {
                        return UpdateListenerWrapper<\(inferredType)> {
                            let stream: AsyncStream<\(inferredType)?> = \(identifier)_storage.valuesStream(forKey: \(keyExpression))

                            return AsyncStream<\(inferredType)> { continuation in
                                let task = Task {
                                    for await element in stream {
                                        if let element {
                                            continuation.yield(element)
                                        } else {
                                            continuation.yield(\(defaultValue))
                                        }
                                    }
                                    continuation.finish()
                                }
                                continuation.onTermination = { _ in
                                    task.cancel()
                                }
                            }
                        }
                    }
                    """
                )
            } else {
                // TODO: Throw
            }
        }

        if let transformerExpression, !transformerExpression.is(KeyPathExprSyntax.self) {
            declarations.append(
                """
                private let \(identifier)_transformer = UserDefaultsStorage(\(transformerExpression))
                """
            )
        }

        return declarations
    }
}

public struct Persist_UserDefaults_NoTransformer: UserDefaultsMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: false,
            isThrowing: false,
            transformerModifier: nil
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
       try expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: false
        )
    }
}

public struct Persist_Storage_NoTransformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: false,
            isThrowing: false,
            transformerModifier: nil
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
       try  _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: false
        )
    }
}

public struct Persist_MutatingStorage_NoTransformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: true,
            isThrowing: false,
            transformerModifier: nil
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: true
        )
    }
}

public struct Persist_ThrowingStorage_NoTransformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: false,
            isThrowing: true,
            transformerModifier: nil
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: false
        )
    }
}

public struct Persist_MutatingThrowingStorage_NoTransformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: true,
            isThrowing: true,
            transformerModifier: nil
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: true
        )
    }
}

public struct Persist_Storage_Transformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: false,
            isThrowing: false,
            transformerModifier: []
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
       try  _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: false
        )
    }
}

public struct Persist_Storage_ThrowingTransformer: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _Persist.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            isMutating: false,
            isThrowing: false,
            transformerModifier: [.throwing]
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
       try  _Persist.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context,
            isMutating: false
        )
    }
}

@main
struct PersistMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Persist_Storage_NoTransformer.self,
        Persist_MutatingStorage_NoTransformer.self,
        Persist_ThrowingStorage_NoTransformer.self,
        Persist_MutatingThrowingStorage_NoTransformer.self,
        Persist_Storage_Transformer.self,
        Persist_Storage_ThrowingTransformer.self,

        // User Defaults

        Persist_UserDefaults_NoTransformer.self,
    ]
}

struct TransformerModifier: OptionSet {
    let rawValue: Int

    static let throwing = TransformerModifier(rawValue: 1 << 0)
}

internal enum _Persist {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        isMutating: Bool,
        isThrowing: Bool,
        transformerModifier: TransformerModifier?
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              binding.accessorBlock == nil
            else {
              return []
            }

        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var keyExpression: ExprSyntax!
        var storageExpression: ExprSyntax!
        var transformerExpression: ExprSyntax?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                keyExpression = argument.expression
            case "storage":
                storageExpression = argument.expression
            case "transformer":
                transformerExpression = argument.expression
            default:
                fatalError("Unknown argument: \(argument)")
            }
        }

        let storage: String

        if let keyPath = storageExpression.as(KeyPathExprSyntax.self) {
            storage = keyPath.components.compactMap { $0.component.as(KeyPathPropertyComponentSyntax.self)?.declName.baseName.trimmed.text }.joined(separator: ".")
        } else {
            storage = "\(identifier)_storage"
        }

        let transformer: String?

        if let keyPath = transformerExpression?.as(KeyPathExprSyntax.self) {
            transformer = keyPath.components.compactMap { $0.component.as(KeyPathPropertyComponentSyntax.self)?.declName.baseName.trimmed.text }.joined(separator: ".")
        } else if transformerExpression != nil {
            transformer = "\(identifier)_transformer"
        } else {
            transformer = nil
        }

        if let defaultValue = binding.initializer?.value {
            let getter: DeclSyntax
            let setter: DeclSyntax

            if let transformer, let transformerModifier {
                if transformerModifier.contains(.throwing) {
                    getter = """
                    get throws {
                        if let storedValue = \(raw: storage).getValue(forKey: \(keyExpression)) {
                            return try \(raw: transformer).transformOutput(storedValue)
                        } else {
                            return \(defaultValue)
                        }
                    }
                    """
                    setter = """
                    \(raw: isMutating ? "mutating" : "nonmutating") set throws {
                        let transformedValue = try \(raw: transformer).transformInput(newValue)
                        \(raw: storage).setValue(transformedValue, forKey: \(keyExpression))
                    }
                    """
                } else {
                    getter = """
                    get {
                        if let storedValue = \(raw: storage).getValue(forKey: \(keyExpression)) {
                            return \(raw: transformer).transformOutput(storedValue)
                        } else {
                            return \(defaultValue)
                        }
                    }
                    """
                    setter = """
                    \(raw: isMutating ? "mutating" : "nonmutating") set {
                        let transformedValue = \(raw: transformer).transformInput(newValue)
                        \(raw: storage).setValue(transformedValue, forKey: \(keyExpression))
                    }
                    """
                }
            } else {
                getter = """
                get {
                    \(raw: storage).getValue(forKey: \(keyExpression)) ?? \(defaultValue)
                }
                """
                setter = """
                \(raw: isMutating ? "mutating" : "nonmutating") set {
                    \(raw: storage).setValue(newValue, forKey: \(keyExpression))
                }
                """
            }

            return [
                """
                \(getter)
                \(setter)
                """
            ]
        } else if binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) == true {
            let getter: DeclSyntax
            let setter: DeclSyntax

            if let transformer, let transformerModifier {
                if transformerModifier.contains(.throwing) {
                    getter = """
                    get throws {
                        if let storedValue = \(raw: storage).getValue(forKey: \(keyExpression)) {
                            return try \(raw: transformer).transformOutput(storedValue)
                        } else {
                            return nil
                        }
                    }
                    """
                    setter = """
                    \(raw: isMutating ? "mutating" : "nonmutating") set throws {
                        if let newValue {
                            let transformedValue = try \(raw: transformer).transformInput(newValue)
                            \(raw: storage).setValue(transformedValue, forKey: \(keyExpression))
                        } else {
                            \(raw: storage).removeValue(forKey: \(keyExpression))
                        }
                    }
                    """
                } else {
                    getter = """
                    get {
                        if let storedValue = \(raw: storage).getValue(forKey: \(keyExpression)) {
                            return \(raw: transformer).transformOutput(storedValue)
                        } else {
                            return nil
                        }
                    }
                    """
                    setter = """
                    \(raw: isMutating ? "mutating" : "nonmutating") set {
                        if let newValue {
                            let transformedValue = \(raw: transformer).transformInput(newValue)
                            \(raw: storage).setValue(transformedValue, forKey: \(keyExpression))
                        } else {
                            \(raw: storage).removeValue(forKey: \(keyExpression))
                        }
                    }
                    """
                }
            } else {
                getter = """
                get {
                    \(raw: storage).getValue(forKey: \(keyExpression))
                }
                """
                setter = """
                \(raw: isMutating ? "mutating" : "nonmutating") set {
                    if let newValue {
                        \(raw: storage).setValue(newValue, forKey: \(keyExpression))
                    } else {
                        \(raw: storage).removeValue(forKey: \(keyExpression))
                    }
                }
                """
            }

            return [
                """
                \(getter)
                \(setter)
                """
            ]
        } else {
            fatalError("Non-optional value must provide a default value")
        }
    }

    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        isMutating: Bool
    ) throws -> [DeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            fatalError("Can only apply to properties")
        }

        let labeledArguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

        var storageExpression: ExprSyntax!
        var transformerExpression: ExprSyntax?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                break
            case "storage":
                storageExpression = argument.expression
            case "transformer":
                transformerExpression = argument.expression
            default:
                fatalError("Unknown argument: \(argument)")
            }
        }

        guard storageExpression != nil else {
            fatalError("storage argument was not provided")
        }

        var declarations: [DeclSyntax] = []

        if !storageExpression.is(KeyPathExprSyntax.self) {
            declarations.append(
                """
                private \(raw: isMutating ? "var" : "let") \(variable.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.trimmed)_storage = \(storageExpression)
                """
            )
        }

        if let transformerExpression, !transformerExpression.is(KeyPathExprSyntax.self) {
            declarations.append(
                """
                private let \(variable.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.trimmed)_transformer = \(transformerExpression)
                """
            )
        }

        return declarations
    }
}

#if canImport(SwiftSyntax510)
import SwiftDiagnostics
#else
@preconcurrency import SwiftDiagnostics
#endif

struct HashableMacroDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    init(id: String, message: String, severity: DiagnosticSeverity) {
        self.message = message
        diagnosticID = MessageID(domain: "Persist", id: id)
        self.severity = severity
    }
}
