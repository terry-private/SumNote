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
    public var option: SumOption?
    public var subtotal: BFraction { unitPrice * quantity }
    public var sum: BFraction { (option?.ratio ?? 1) * subtotal }

    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, unitPrice: BFraction, quantity: BFraction, unitName: String, option: SumOption? = nil ) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unitName = unitName
        self.option = option
    }
}

extension SumItem {
    public var unitPriceDescription: String { "\(unitPrice.ex.currencyString())円/\(unitName)" }
    public var quantityDescription: String { "x \(quantity.ex.currencyString())\(unitName)" }
    public var sumDescription: String { "= \(sum.ex.currencyString())円" }
    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
        let items: [String?] = [
            "\(name) \(unitPriceDescription)".indent(indent, spaces: spaces),
            quantityDescription.indent(indent + 1, spaces: spaces),
            option?.description.indent(indent + 1, spaces: spaces),
            sumDescription.indent(indent + 1, spaces: spaces),
        ]
        return items.compactMap{ $0 }.joined(separator: "\n")
    }
    public var description: String {
        "\(name)\n \(unitPrice.ex.currencyString())円/\(unitName) x \(quantity.ex.currencyString())\(unitName) \(option?.description ?? "") = \(sum.ex.currencyString())円"
    }
    public static func dummy(_ index: Int) -> Self {
        SumItem(name: "item_name_\(index)", unitPrice: BFraction(index, 1), quantity: BFraction(index, 1), unitName: "個", option: .dummy(index))
    }
}
