import BigInt

// MARK: - BInt -
extension BInt: @unchecked @retroactive Sendable {}
extension BInt: @retroactive RawRepresentable, Codable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }
    public var rawValue: String {
        description
    }
}

// MARK: - BFraction -
extension BFraction: @unchecked @retroactive Sendable, @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(numerator)
        hasher.combine(denominator)
    }
}

extension BFraction: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(numerator, forKey: .numerator)
        try container.encode(denominator, forKey: .denominator)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let numerator = try values.decode(BInt.self, forKey: .numerator)
        let denominator = try values.decode(BInt.self, forKey: .denominator)
        self.init(numerator, denominator)
    }
    
    enum CodingKeys: CodingKey {
        case numerator
        case denominator
    }
}

extension BFraction {
    public var wholePart: String {
        truncate().description
    }
    public func fractionalPart(rounded: Int) -> String {
        asDecimalString(precision: rounded + wholePart.count).split(separator: ".")[1].description
    }
    public func decimalString(rounded: Int) -> String {
        asDecimalString(precision: rounded + wholePart.count).dropLast0()
    }
    public var currencyWholePart: String {
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
    public var currency: String {
        "\(currencyWholePart).\(fractionalPart(rounded: 2))".dropLast0()
    }
}
