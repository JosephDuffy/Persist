import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol UserDefaultsMacro: AccessorMacro, PeerMacro {}

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
            transformerModifier: []
        )
    }
}

public struct Persist_UserDefaults_Transformer: UserDefaultsMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            transformerModifier: []
        )
    }
}

public struct Persist_UserDefaults_ThrowingTransformer: UserDefaultsMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            transformerModifier: [.throwingInput, .throwingOutput]
        )
    }
}

public struct Persist_UserDefaults_ThrowingInputTransformer: UserDefaultsMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            transformerModifier: [.throwingInput]
        )
    }
}

public struct Persist_UserDefaults_ThrowingOutputTransformer: UserDefaultsMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context,
            transformerModifier: [.throwingOutput]
        )
    }
}

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
        transformerModifier: TransformerModifier
    ) throws -> [AccessorDeclSyntax] {
        guard let property = declaration.as(VariableDeclSyntax.self),
              let binding = property.bindings.first,
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

        let transformer: (type: ExprSyntax, initialiser: ExprSyntax)?

        if let transformerExpression {
            if let functionCall = transformerExpression.as(FunctionCallExprSyntax.self) {
                // TODO: Check if calledExpression is `DeclReferenceExpr` or `MemberAccessExpr`.
                transformer = (
                    type: functionCall.calledExpression,
                    initialiser: transformerExpression
                )
            } else {
                throw HashableMacroDiagnosticMessage(
                    id: "incompatible-transformer",
                    message: "Could not determine the type of the transformer. Please provide a call to an initialiser.",
                    severity: .error
                )
            }
        } else {
            transformer = nil
        }

        guard let keyExpression else {
            throw HashableMacroDiagnosticMessage(
                id: "missing-key-parameter",
                message: "The 'key' parameter must be provided.",
                severity: .error
            )
        }

        let userDefaultsPropertyName = try userDefaultsAccessor(labeledArguments: labeledArguments)

        if let transformer {
            let getter: DeclSyntax
            let setter: DeclSyntax

            let isOptional = typeAnnotation.type.is(OptionalTypeSyntax.self)

            // TODO: Remove force try!
            var valueAccessor = """
            if let storedValue = \(userDefaultsPropertyName).object(forKey: \(keyExpression)) as? \(transformer.type.trimmedDescription).Output {
                    let transformer = \(transformer.initialiser.trimmedDescription)
                    return try! transformer.transformOutput(storedValue)
            }
            """

            if isOptional {
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

            if transformerModifier.contains(.throwingInput) {
                getter = """
                get throws(\(raw: transformer.type.trimmedDescription).TransformInputError) {
                    \(raw: valueAccessor)
                }
                """
                setter = """
                nonmutating set throws(\(raw: transformer.type.trimmedDescription).TransformOutputError) {
                    if let newValue {
                        let transformer = \(transformer.initialiser)
                        let transformedValue = try transformer.transformInput(newValue)
                        \(raw: userDefaultsPropertyName).set(transformedValue, forKey: \(keyExpression))
                    } else {
                        \(raw: userDefaultsPropertyName).removeObject(forKey: \(keyExpression))
                    }
                }
                """
            } else {
                getter = """
                get {
                    \(raw: valueAccessor)
                }
                """
                setter = """
                nonmutating set {
                    if let newValue {
                        let transformer = \(transformer.initialiser)
                        let transformedValue = try! transformer.transformInput(newValue)
                        \(raw: userDefaultsPropertyName).set(transformedValue, forKey: \(keyExpression))
                    } else {
                        \(raw: userDefaultsPropertyName).removeObject(forKey: \(keyExpression))
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

            let valueSetter = """
            \(userDefaultsPropertyName).set(newValue, forKey: \(keyExpression))
            """

            func valueAccessor(forBaseType baseType: BaseType) throws -> String {
                switch baseType {
                case .optional(let baseType):
                    try valueAccessor(forBaseType: baseType)
                case .identifier(let identifierTypeSyntax):
                    // Support all types included in https://github.com/swiftlang/swift-corelibs-foundation/blob/main/Sources/Foundation/UserDefaults.swift#L25
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

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
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
