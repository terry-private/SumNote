import Foundation
import BigIntExtensions

public struct SumDiscount: EntityProtocol {
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
    public init(id: ID = .newID, style: Style = .percentile, _ numerator: Int = 0) {
        self.id = id
        self.style = style
        self.numerator = numerator
    }
}

public extension SumDiscount {
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
    func discountPrice(_ price: BFraction) -> BFraction {
        BFraction(numerator, .init(denominator)) * price
    }
    func discountPriceDescription(_ price: BFraction) -> String {
        numerator == .zero ? "" : "- \(discountPrice(price).ex.currencyString())円(\(labelText))"
    }
    static var dummy: Self {
        .init(style: .percentile, 15)
    }
    static func dummy(_ number: Int) -> Self {
        .init(style: .decile, number % 10)
    }
}

extension SumDiscount {
    public struct Style: Sendable, Hashable, Codable, Identifiable, Equatable {
        public var id: Self { self }
        public var name: String
        public var discountSuffix: String
        public var denominator: Int
        public init(name: String, discountSuffix: String, denominator: Int) {
            precondition(denominator > 0)
            self.name = name
            self.discountSuffix = discountSuffix
            self.denominator = denominator
        }

        public var selectableRange: Range<Int> { 0..<denominator }
    }
}

extension SumDiscount.Style: CaseIterable {
    public static var decile: Self { .init(name: "割", discountSuffix: "引", denominator: 10) }
    public static var percentile: Self { .init(name: "%", discountSuffix: "off", denominator: 100) }
    public static var allCases: [Self] {
        [
            .decile,
            .percentile
        ]
    }
}
