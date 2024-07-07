import BigInt

extension BFraction {
    public struct Extension {
        private let fraction: BFraction
        fileprivate init(fraction: BFraction) {
            self.fraction = fraction
        }
    }
    public var ex: Extension { .init(fraction: self) }
}

public extension BFraction.Extension {
    /// 整数部分の文字列
    var wholePart: String {
        fraction.truncate().description
    }
    /// 小数点以下の文字列
    func fractionalPart(rounded: Int) -> String {
        guard fraction.denominator != 1 else {
            return ""
        }
        // 1以下の部分のみ扱う
        let fraction = fraction - fraction.truncate()
        var log2 = 0
        var log5 = 0
        // 分母の素因数を2と5以外のものに分解
        var denominator = fraction.denominator
        while denominator % 2 == 0 {
            denominator /= 2
            log2 += 1
        }
        while denominator % 5 == 0 {
            denominator /= 5
            log5 += 1
        }
        // 残りの分母が1でない場合、循環小数になる
        let rounded = denominator != 1 ? rounded : min(rounded, max(log2, log5))
        return fraction.asDecimalString(precision: rounded).split(separator: ".")[1].description
    }
    var currencyWholePart: String {
        let string = wholePart
        var result = ""
        let lastIndex = string.count - 1
        for (index, char) in string.enumerated() {
            if index > 0 && (lastIndex - index + 1) % 3 == 0 {
                result.append(",")
            }
            result.append(char)
        }
        return result
    }
    func asDecimalString(max rounded: Int) -> String {
        if fraction.denominator == 1 {
            wholePart
        } else {
            wholePart + "." + fractionalPart(rounded: rounded)
        }
    }
}
