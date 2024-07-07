import Testing
import BigInt
@testable import Components

struct BgIntTests {

    @Suite("Braction.Extensionのテスト")
    struct BFractionExtensionsTests {
        @Test("currencyWholePart", arguments: zip(
            [
                BFraction(100, 1),
                BFraction(1000, 1),
                BFraction(1000000, 1),
            ],
            ["100", "1,000", "1,000,000"]
        ))
        func currencyWholePartTest(
            fraction: BFraction,
            ans: String
        ) async throws {
            #expect(fraction.ex.currencyWholePart == ans)
        }
        @Test("fractionalPart with rounded: 2", arguments: zip(
            [
                BFraction(1, 1),
                BFraction(1, 2),
                BFraction(1, 4),
                BFraction(1, 8),
                BFraction(1357, 100)
            ],
            ["", "5", "25", "125", "57"]
        ))
        func cfractionalPartTest(
            fraction: BFraction,
            ans: String
        ) async throws {
            #expect(fraction.ex.fractionalPart(rounded: 3) == ans)
        }
    }

}
