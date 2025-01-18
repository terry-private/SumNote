import Foundation
import BigIntExtensions


public struct SumOption: EntityProtocol {
    public enum Style: Sendable, Hashable, Codable, CaseIterable, Identifiable {
        case decile
        case percentile
        public var id: Self { self }
        public var name: String {
            switch self {
            case .decile: return "割"
            case .percentile: return "%"
            }
        }
        public var discountSuffix: String {
            switch self {
            case .decile: return "引"
            case .percentile: return "off"
            }
        }
        public var denominator: Int {
            switch self {
            case .decile: return 10
            case .percentile: return 100
            }
        }
    }
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var style: Style
    public var numerator: Int
    public var name: String { style.name }
    public var discountSuffix: String { style.discountSuffix }
    public var denominator: Int { style.denominator }
    public var ratio: BFraction { (BFraction(denominator, 1) - numerator) / denominator }
    public init(id: ID = .init(rawValue: UUID().uuidString), style: Style = .percentile, _ numerator: Int = 0) {
        self.id = id
        self.style = style
        self.numerator = numerator
    }
}

public extension SumOption {
    var suffix: String { "\(name)\(discountSuffix)"}
    var labelText: String {
        "\(numerator)\(suffix)"
    }
    func description(with indent: Int = 0) -> String {
        description.indent(indent)
    }
    var description: String {
        numerator == .zero ? "" : "x \(ratio.ex.currencyString()) (\(labelText))"
    }
    static var dummy: Self {
        .init(style: .percentile, 15)
    }
    static func dummy(_ number: Int) -> Self {
        .init(style: .decile, number % 10)
    }
}
