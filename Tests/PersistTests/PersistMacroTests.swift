import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PersistMacros)
import PersistMacros

let testMacros: [String: Macro.Type] = [
    "Persist": Persist.self,
]
#endif

final class PersistMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(PersistMacros)
        assertMacroExpansion(
            """
            struct Setting {
                @Persist(storage: UserDefaultsStorage(.standard))
                var testProperty: Int = 0
            }
            """,
            expandedSource: """
            struct Setting {
                var testProperty: Int {
                    get {
                        testProperty_storage.getValue(forKey: "foo") ?? 0
                    }
                    set {
                        testProperty_storage.setValue(newValue, forKey: "foo")
                    }
                }

                private let testProperty_storage = UserDefaultsStorage(.standard)
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
