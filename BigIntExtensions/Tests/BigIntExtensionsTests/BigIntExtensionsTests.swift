import Testing
@testable import BigIntExtensions

//@Test func example() async throws {
//    let fraction: BFraction = .init(100000000000, 999999)
//    print("=====  asDecimalString  =====")
//    print("true", fraction.asDecimalString(precision: 10, exponential: true))
//    print("false", fraction.asDecimalString(precision: 10, exponential: false))
//    print("=====  decimalString  =====")
//    print("normal", fraction.decimalString(rounded: 2))
//    print("ex", fraction.ex.asDecimalString(max: 2))
//
//
//    print("=====  fractionalPart  =====")
//    print("normal", fraction.ex.fractionalPart(rounded: 2))
//    print("ex", fraction.fractionalPart(rounded: 2))
//
//    print("=====  currencyWholePart  =====")
//    print("normal", fraction.currencyWholePart)
//    print("ex", fraction.ex.currencyWholePart)
//    print(fraction.abs.currency)
//
//}

@Suite("Bfraction.Extensionのテスト")
struct BfractionExtensionsTests {
    @Test("wholePart 符号が付く ３けた区切りは無し", arguments: [
        (BFraction(10, 3), "3"),
        (BFraction(-10, 3), "-3"),
        (BFraction(-1, 3), "0"),
        (BFraction(0, -3), "0"),
        (BFraction(100_000, 1), "100000")
    ])
    func wholePartTests(arg: (BFraction, String)) {
        #expect(arg.0.ex.wholePartString == arg.1)
    }

    @Suite("fractionalPartのテスト")
    struct FractionalPartTests {
        @Test("rounded: 0 の場合 空文字", arguments: [
            BFraction(1, 3),
            BFraction(-1, 3),
            BFraction(-0, 3),
            BFraction(100_000, 1),
        ])
        func fractionalPartRounded0(fraction: BFraction) {
            #expect(fraction.ex.fractionalPartString(rounded: 0) == "")
        }

        @Test("rounded: 1以上は小数点以下のrounded桁まで表示")
        func fractionalPartRoundedMoreThan1() {
            #expect(BFraction(1, 3).ex.fractionalPartString(rounded: 2) == "33")
            #expect(BFraction(1, 3).ex.fractionalPartString(rounded: 3) == "333")
            #expect(BFraction(10, 3).ex.fractionalPartString(rounded: 2) == "33")
            #expect(BFraction(10, 3).ex.fractionalPartString(rounded: 3) == "333")
            #expect(BFraction(1000000, 3).ex.fractionalPartString(rounded: 2) == "33")
            #expect(BFraction(1000000, 3).ex.fractionalPartString(rounded: 3) == "333")
        }

        @Test("小数点として表示分以降が0のみの場合は0を削除")
        func divisibleFractionDropZero() {
            #expect(BFraction(1, 2).ex.fractionalPartString(rounded: 1) == "5")
            #expect(BFraction(1, 2).ex.fractionalPartString(rounded: 100) == "5")
            #expect(BFraction("0.5")?.ex.fractionalPartString(rounded: 1) == "5")
            #expect(BFraction("0.50")?.ex.fractionalPartString(rounded: 100) == "5")
            #expect(BFraction(-1, 2).ex.fractionalPartString(rounded: 2) == "5")

        }
        @Test("小数点として表示分以降どこかに0以外数字がある場合は0を削除しない")
        func divisibleFractionNotDropZero() {
            #expect(BFraction("0.1")?.ex.fractionalPartString(rounded: 2) == "1")
            #expect(BFraction("0.101")?.ex.fractionalPartString(rounded: 2) == "10")
            #expect(BFraction("0.101")?.ex.fractionalPartString(rounded: 3) == "101")
            #expect(BFraction("0.101")?.ex.fractionalPartString(rounded: 4) == "101")
            #expect(BFraction("0.101")?.ex.fractionalPartString(rounded: 100) == "101")
        }

    }
    @Test("currencyWholePart 符号が付く ３けた区切りは有り", arguments: [
        (BFraction(1_000_000, 3), "333,333"),
        (BFraction(-1, 3), "0"),
        (BFraction(-0, 3), "0"),
        (BFraction(-100, 1), "-100"),
        (BFraction(-1000, 1), "-1,000")
    ])
    func currencyWholePartPartTests(arg: (BFraction, String)) {
        #expect(arg.0.ex.currencyWholePartString == arg.1)
    }

    @Test("decimalString 符号が付く ３けた区切りは無し", arguments: [
        (BFraction(1_000, 3), "333.33"), // roundedは小数点以下のみ
        (BFraction(-1, 3), "-0.33"), // マイナス記号がちゃんとつく
        (BFraction(-0, 3), "0"), // 0の時は0のみ
        (BFraction(100_000, 1), "100000") // 3桁区切りなし
    ])
    func decimalString_max2(arg: (BFraction, String)) {
        #expect(arg.0.ex.decimalString(max: 2) == arg.1)
    }

    @Test("decimalString 符号が付く ３けた区切りはあり", arguments: [
        (BFraction(1_000, 3), "333.33"), // roundedは小数点以下のみ
        (BFraction(-1, 3), "-0.33"), // マイナス記号がちゃんとつく
        (BFraction(-0, 3), "0"), // 0の時は0のみ
        (BFraction(100_000, 1), "100,000"), // 3桁区切りあり
        (BFraction("10000.100")!, "10,000.1"), // 3桁区切りあり, rounded以上の桁に0以外がないなら0を省略
        (BFraction("10000.101")!, "10,000.10") // 3桁区切りあり, rounded以上の桁に0以外があるなら0を省略しない
    ])
    func currencyString_rounded2(arg: (BFraction, String)) {
        #expect(arg.0.ex.currencyString(rounded: 2) == arg.1)
    }
}
