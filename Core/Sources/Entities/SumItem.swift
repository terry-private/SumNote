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
    public var unitOption: UnitOption?
    public var unitName: String
    public var discount: SumDiscount

    public init(id: ID = .newID, name: String, unitPrice: BFraction, quantity: BFraction, unitOption: UnitOption? = nil, unitName: String, discount: SumDiscount = .init() ) {
        self.id = id
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.unitOption = unitOption
        self.unitName = unitName
        self.discount = discount
    }
}
extension SumItem {
    public var baseUnitQuantity: BFraction {
        unitOption?.baseUnitQuantity ?? .ONE
    }
    public var subtotal: BFraction { unitPrice / baseUnitQuantity * quantity }
    public var sum: BFraction { (discount.ratio) * subtotal }
}
extension SumItem {
    public var quantityUnitName: String { unitOption?.unitName ?? unitName }
    public var baseUnitName: String {
        unitOption?.baseUnitName ?? unitName
    }
    public var unitPriceName: String {
        "円/\(baseUnitName)"
    }
}

extension SumItem {
    public var unitPriceDescription: String { "\(unitPrice.ex.currencyString())\(unitPriceName)" }
    public var quantityDescription: String { "x \(quantity.ex.currencyString())\(unitName)" }
    public var sumDescription: String { "= \(sum.ex.currencyString())円" }
    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
        let items: [String?] = [
            "\(name) \(unitPriceDescription)".indent(indent, spaces: spaces),
            quantityDescription.indent(indent + 1, spaces: spaces),
            discount.numerator == .zero ? nil : discount.description.indent(indent + 1, spaces: spaces),
            sumDescription.indent(indent + 1, spaces: spaces),
        ]
        return items.compactMap{ $0 }.joined(separator: "\n")
    }
    public var description: String {
        "\(name)\n \(unitPrice.ex.currencyString())\(unitPriceName) x \(quantity.ex.currencyString())\(unitName) \(discount.description) = \(sum.ex.currencyString())円"
    }
    public static func dummy(_ index: Int) -> Self {
        SumItem(name: "item_name_\(index)", unitPrice: BFraction(index, 1), quantity: BFraction(index, 1), unitName: "個", discount: .dummy(index))
    }
}
