import BigIntExtensions
import Foundation

public struct UnitOption: Sendable, Codable, Hashable, Identifiable, Equatable {
    public var id: String { name }
    public var name: String
    public var baseUnitQuantity: BFraction
    public var unitName: String

    public init(name: String, baseUnitQuantity: BFraction, unitName: String) {
        self.name = name
        self.baseUnitQuantity = baseUnitQuantity
        self.unitName = unitName
    }

    public var baseUnitName: String {
        "\(baseUnitQuantity.ex.currencyString())\(unitName)"
    }
}

public extension UnitOption {
    static var meat: UnitOption {
        .init(
            name: "肉系",
            baseUnitQuantity: 100,
            unitName: "g"
        )
    }
}
