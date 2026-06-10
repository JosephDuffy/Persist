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
