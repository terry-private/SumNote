import Foundation
import Testing
import BigInt
@testable import Entities
@testable import Components

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
        @Test("BInt")
        func bIntTests() throws {
            let fraction = BFraction(7777, 256)
            pr(fraction.numerator)
            pr(fraction.denominator)
            pr(fraction.asDecimalString(precision: 20))
            pr("循環小数？", fraction.hasRepeatingDecimal())
            pr(fraction.asDouble())
            let double = (fraction - fraction.numerator / fraction.denominator).asDouble()
            pr(7777-97, double)
            pr(double.description)
        }
    }
}

func pr(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n"
) {
    print(["|"] as [Any] + items, separator: separator, terminator: terminator)
}

extension Tag {
    @Tag static var operation: Tag
}

