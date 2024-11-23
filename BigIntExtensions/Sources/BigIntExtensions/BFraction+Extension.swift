extension String {
    public func dropLast0() -> String {
        var str = self
        while str.hasSuffix("0") && str.contains(".") {
            str = String(str.dropLast())
        }
        if str.hasSuffix(".") {
            str = String(str.dropLast())
        }
        return str
    }
}

extension BFraction {
    public init(_ int: BInt) {
        self = .init(int, .ONE)
    }
}

extension BFraction: @retroactive ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .init(.init(value))
    }
}

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
    var wholePartString: String {
        fraction.truncate().description
    }
    /// 小数点以下の文字列
    func fractionalPartString(rounded: Int) -> String {
        guard fraction.denominator != .ONE else { return "" }
        guard rounded > 0 else { return "" }
        let wholePartDigits = fraction.truncate().isZero ? 0 : fraction.abs.truncate().description.count
        let roundedWithWholePartDigits = rounded + wholePartDigits
        let roundedFractionString = fraction.asDecimalString(precision: roundedWithWholePartDigits)
        let roundedFraction = BFraction(roundedFractionString)
        if fraction == roundedFraction {
            return roundedFractionString.dropLast0().split(separator: ".")[1].description
        } else {
            return roundedFractionString.split(separator: ".")[1].description
        }
    }
    var currencyWholePartString: String {
        let string = fraction.abs.truncate().description
        var result = ""
        let lastIndex = string.count - 1
        for (index, char) in string.enumerated() {
            if index > 0 && (lastIndex - index + 1) % 3 == 0 {
                result.append(",")
            }
            result.append(char)
        }
        return "\(fraction.numerator.isNegative ? "-" : "")\(result)"
    }
    func decimalString(max rounded: Int) -> String {
        if fraction.denominator == 1 {
            wholePartString
        } else {
            "\(fraction.isNegative ? "-" : "")\(fraction.abs.truncate().description)" + "." + fractionalPartString(rounded: rounded)
        }
    }
    func currencyString(rounded: Int = 2) -> String {
        "\(currencyWholePartString).\(fractionalPartString(rounded: rounded))"
    }
}
