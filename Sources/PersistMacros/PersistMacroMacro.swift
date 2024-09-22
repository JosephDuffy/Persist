import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol UserDefaultsMacro: AccessorMacro, PeerMacro {}

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
            case "userDefaults":
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

        var keyExpression: ExprSyntax!
        var storageExpression: ExprSyntax!
        var transformerExpression: ExprSyntax?

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                keyExpression = argument.expression
            case "userDefaults":
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

        if !storageExpression.is(KeyPathExprSyntax.self) {
            declarations.append(
                """
                private \(raw: isMutating ? "var" : "let") \(identifier)_storage = UserDefaultsStorage(\(storageExpression))
                """
            )
        }

        if typeAnnotation.is(OptionalTypeSyntax.self) {
            declarations.append(
                """
                var $\(identifier): UpdateListenerWrapper<\(inferredType)> {
                    return UpdateListenerWrapper<\(inferredType)>(
                        valuesStreamProvider: { @Sendable () -> AsyncStream<\(inferredType)> in
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
