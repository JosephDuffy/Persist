//#if os(macOS) || os(iOS) || os(tvOS)
//import XCTest
//@testable import Persist
//
//final class StorableInNSUbiquitousKeyValueStoreTests: XCTestCase {
//
//    func testBool() {
//        XCTAssertEqual(true.asNSUbiquitousKeyValueStoreValue, .bool(true))
//    }
//
//    func testString() {
//        XCTAssertEqual("test-value".asNSUbiquitousKeyValueStoreValue, .string("test-value"))
//    }
//
//    func testData() {
//        XCTAssertEqual(Data().asNSUbiquitousKeyValueStoreValue, .data(Data()))
//    }
//
//    func testInt64() {
//        XCTAssertEqual(Int64(123).asNSUbiquitousKeyValueStoreValue, .int64(123))
//    }
//
//    func testDouble() {
//        XCTAssertEqual(Double(123.45).asNSUbiquitousKeyValueStoreValue, .double(123.45))
//    }
//
//    func testArray() {
//        XCTAssertEqual([Int64(123)].asNSUbiquitousKeyValueStoreValue, .array([.int64(123)]))
//    }
//
//    func testDictionary() {
//        XCTAssertEqual(
//            [
//                "test-key": Int64(123)
//            ].asNSUbiquitousKeyValueStoreValue,
//            .dictionary([
//                "test-key": .int64(123)
//            ])
//        )
//    }
//
//}
//#endif
