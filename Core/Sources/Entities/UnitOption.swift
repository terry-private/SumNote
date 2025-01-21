import BigIntExtensions
import Foundation

public struct UnitOption: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public var id: ID
    public var name: String
    public var baseUnitQuantity: BFraction
    public var unitName: String

    public init(id: ID = .newID, name: String, baseUnitQuantity: BFraction, unitName: String) {
        self.id = id
        self.name = name
        self.baseUnitQuantity = baseUnitQuantity
        self.unitName = unitName
    }
}

public extension UnitOption {
    static var meat: UnitOption {
        .init(
            id: .newID,
            name: "肉系",
            baseUnitQuantity: 100,
            unitName: "g"
        )
    }
}
