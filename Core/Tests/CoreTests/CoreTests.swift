//import XCTest
//
//final class CoreTests: XCTestCase {
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
//}
import Foundation
import Testing
@testable import Entities

struct EntitiesTests {
    @Suite("基本的なテスト")
    struct BasicTests {
        @Test(.disabled("クラッシュします"), .bug("https://www.notion.so/DeOikura-ca5bac49aa5a4dd69e3347ee95402459", ""))
        func entityTests() throws {
            let aa: [Int] = []
            let firstA = try #require(aa.first)
            #expect(firstA == 0)
        }
        @Test("足し算", .tags(.operation)) func additionTests() throws {
            #expect(1+1 == 2)
        }
    }
}

extension Tag {
    @Tag static var operation: Tag
}
