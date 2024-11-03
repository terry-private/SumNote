import Foundation
import BigIntExtensions

public struct SumItem: EntityProtocol {
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
    public var options: [SumOption]
    public var subtotal: BFraction { unitPrice * quantity }
    public var sum: BFraction { options.map(\.ratio).reduce(subtotal, *) }

    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, unitPrice: BFraction, quantity: BFraction, unitName: String, options: [SumOption] = []) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unitName = unitName
        self.options = options
    }
}

extension SumItem {
    public func description(with indent: Int = 0) -> String {
        let subtotal = "\(name) \(unitPrice.ex.currencyString())円/\(unitName) x \(quantity.ex.currencyString())\(unitName) = \(subtotal.ex.currencyString())円".indent(indent)
        guard !options.isEmpty else { return subtotal }

        let optionDescriptions = options.map {
            $0.description(with: indent + 1)
        }
        let sum = "= \(sum.ex.currencyString())円".indent(indent + 1)
        let rows = [subtotal] + optionDescriptions + [sum]
        return rows.joined(separator: "\n")
    }
    public var description: String {
        "\(name)\n \(unitPrice.ex.currencyString())円/\(unitName) x \(quantity.ex.currencyString())\(unitName) = \(sum.ex.currencyString())円"
    }
}

public extension SumItem {
    static func dummy(_ index: Int) -> Self {
        SumItem(id: "row_id_\(index)", name: "row_name_\(index)", unitPrice: BFraction(index, 1), quantity: BFraction(index, 1), unitName: "個", options: [.dummy(index)])
    }
}
