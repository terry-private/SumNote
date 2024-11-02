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
