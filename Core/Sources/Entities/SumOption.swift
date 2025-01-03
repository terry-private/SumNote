import Foundation
import BigIntExtensions

public struct SumOption: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var numerator: BFraction
    public var denominator: Int
    public var ratio: BFraction { (BFraction(denominator, 1) - numerator) / denominator }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, numerator: BFraction, denominator: Int = 100) {
        self.id = id
        self.name = name
        self.numerator = numerator
        self.denominator = denominator
    }
}

public extension SumOption {
    var prefix: String { "\(name) off"}
    var labelText: String {
        "\(numerator.ex.currencyString())\(prefix)"
    }
    func description(with indent: Int = 0) -> String {
        description.indent(indent)
    }
    var description: String {
        "x \(ratio.ex.currencyString()) (\(labelText))"
    }
    static var dummy: Self {
        .init(name: "%", numerator: 80)
    }
    static func dummy(_ number: Int) -> Self {
        return .init(name: "割", numerator: .init(number % 10, 1), denominator: 10)
    }
}
