import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Persist: AccessorMacro, PeerMacro {
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
            isThrowing: false
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

public struct Persist_Mutating: AccessorMacro, PeerMacro {
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
            isThrowing: false
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
            isMutating: true
        )
    }
}

@main
struct PersistMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Persist.self,
        Persist_Mutating.self,
    ]
}

internal enum _Persist {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext,
        isMutating: Bool,
        isThrowing: Bool
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

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                keyExpression = argument.expression
            case "storage":
                storageExpression = argument.expression
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

        if let defaultValue = binding.initializer?.value {
            return [
                """
                get {
                    \(raw: storage).getValue(forKey: \(keyExpression)) ?? \(defaultValue)
                }
                \(raw: isMutating ? "mutating" : "nonmutating") set {
                    \(raw: storage).setValue(newValue, forKey: \(keyExpression))
                }
                """
            ]
        } else if binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) == true {
            return [
                """
                get {
                    \(raw: storage).getValue(forKey: \(keyExpression))
                }
                \(raw: isMutating ? "mutating" : "nonmutating") set {
                    if let newValue {
                        \(raw: storage).setValue(newValue, forKey: \(keyExpression))
                    } else {
                        \(raw: storage).removeValue(forKey: \(keyExpression))
                    }
                }
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

        for argument in labeledArguments {
            switch argument.label?.trimmed.text {
            case "key":
                break
            case "storage":
                storageExpression = argument.expression
            default:
                fatalError("Unknown argument: \(argument)")
            }
        }

        guard storageExpression != nil else {
            fatalError("storage argument was not provided")
        }

        if storageExpression.is(KeyPathExprSyntax.self) {
            return []
        } else {
            return [
                """
                private \(raw: isMutating ? "var" : "let") \(variable.bindings.first!.pattern.as(IdentifierPatternSyntax.self)!.identifier.trimmed)_storage = \(storageExpression)
                """
            ]
        }
    }
}
