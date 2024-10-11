import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PersistMacros)
import PersistMacros
#endif

final class PersistMacroTests: XCTestCase {
    func testUserDefaultsTransformer() throws {
        #if canImport(PersistMacros)
        assertMacroExpansion(
            """
            struct Setting {
                @Persist(
                    key: "transformed-key",
                    userDefaults: .standard,
                    transformer: JSONTransformer<TaskPriority>()
                )
                var transformedProperty: TaskPriority?
            }
            """,
            expandedSource: """
            struct Setting {
                var transformedProperty: TaskPriority?
            }
            """,
            macros: [
                "Persist": Persist_UserDefaults_NoTransformer.self,
            ]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
