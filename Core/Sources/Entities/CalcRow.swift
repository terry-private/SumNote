import Foundation
import BigInt

public struct CalcRow: Sendable, Hashable, Codable, Equatable, Identifiable {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var unitPrice: BFraction
    public var quantity: BFraction
    public var unitName: String
    public var sum: BFraction { unitPrice * quantity }

    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, unitPrice: BFraction, quantity: BFraction, unitName: String) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unitName = unitName
    }
}

extension CalcRow: CustomStringConvertible {
    public var description: String {
        "\(name)\n \(unitPrice.currency)円/\(unitName) x \(quantity.currency)\(unitName) = \(sum.currency)円"
    }
}

public extension CalcRow {
    static func dummy(_ index: Int) -> Self {
        CalcRow(id: "row_id_\(index)", name: "row_name_\(index)", unitPrice: BFraction(index, 1), quantity: BFraction(index, 1), unitName: "個")
    }
}
