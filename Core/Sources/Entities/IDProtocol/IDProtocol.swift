public protocol IDProtocol: RawRepresentable, Hashable, Sendable, Identifiable, Codable, CustomStringConvertible where RawValue: Hashable & Sendable & Codable & CustomStringConvertible {
    init(rawValue: RawValue)
}

extension IDProtocol {
    public var description: String {
        rawValue.description
    }
    public var id: Self { self }
}

public protocol StringIDProtocol: IDProtocol, ExpressibleByStringInterpolation where RawValue == String {}

extension StringIDProtocol {
    public init(stringLiteral value: String) {
        self.init(rawValue: RawValue(stringLiteral: value))
    }

    public init(stringInterpolation: RawValue.StringInterpolation) {
        self.init(rawValue: RawValue(stringInterpolation: stringInterpolation))
    }
}
