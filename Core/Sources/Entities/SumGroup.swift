import Foundation
import BigInt

public enum SumRow: EntityProtocol {
    case group(SumGroup2)
    case item(SumItem2)
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public var id: ID {
        let rawValue = switch self {
        case .group(let group): group.id.rawValue
        case .item(let item): item.id.rawValue
        }
        return ID(rawValue: rawValue)
    }
    public var name: String {
        switch self {
        case .group(let group): group.name
        case .item(let item): item.name
        }
    }
    public func sum() -> BFraction {
        switch self {
        case .group(let group): group.sum()
        case .item(let item): item.sum
        }
    }
    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
        switch self {
        case .group(let group): group.description(with: indent, spaces: spaces)
        case .item(let item): item.description(with: indent, spaces: spaces)
        }
    }
    static func dummy(_ index: Int) -> Self {
        .group(SumGroup2(name: "group_\(index)", items: (1...index).map { _ in .dummy(0) }))
    }
}

public struct SumGroup2: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var items: [SumItem]
    public init(id: ID = .ID(rawValue: UUID().uuidString), name: String, items: [SumItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
    public func sum() -> BFraction {
        items.reduce(.ZERO) {
            $0 + $1.sum
        }
    }

    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
        var rowTexts: [String] = [name.indent(indent, spaces: spaces)]
        for item in items {
            rowTexts.append(item.description(with: indent + 1))
        }
        rowTexts.append("合計 \(sum().ex.currencyString()) 円".indent(indent + 1))
        return rowTexts.joined(separator: "\n")
    }

}

public struct SumItem2: EntityProtocol {
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

extension SumItem2 {
    public var unitPriceDescription: String { "\(unitPrice.ex.currencyString())円/\(unitName)" }
    public var quantityDescription: String { "x \(quantity.ex.currencyString())\(unitName)" }
    public var sumDescription: String { "= \(sum.ex.currencyString())円" }
    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
//        let subtotal = "\(name) \(unitPrice.ex.currencyString())円/\(unitName) x \(quantity.ex.currencyString())\(unitName) = \(subtotal.ex.currencyString())円".indent(indent)
//        let header = "\(name)"
//        let
//        guard let option else { return subtotal }
//
//        let optionDescription = option.description(with: indent + 1)
//        let sum = "= \(sum.ex.currencyString())円".indent(indent + 1)
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
    static func dummy(_ index: Int) -> Self {
        SumItem2(name: "item_name_\(index)", unitPrice: BFraction(index, 1), quantity: BFraction(index, 1), unitName: "個", option: .dummy(index))
    }
}

public struct SumGroup: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var items: [SumItem]
    public var sum: BFraction {
        items.reduce(.ZERO) {
            $0 + $1.sum
        }
    }

    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, items: [SumItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
}

extension SumGroup: CustomStringConvertible {
    public func description(with indent: Int = 0) -> String {
        var rowTexts: [String] = [name.indent(indent)]
        for row in items {
            rowTexts.append(row.description(with: indent + 1))
        }
        rowTexts.append("合計 \(sum.ex.currencyString()) 円".indent(indent + 1))
        return rowTexts.joined(separator: "\n")
    }

    public var description: String {
        """
        \(name)
         \(items.flatMap {
            $0.description.split(separator: "\n")
            }.joined(separator: "\n ")
        )
        合計 \(sum.ex.currencyString()) 円
        """
    }
}
public extension SumGroup {
    static func dummy(_ index: Int) -> Self {
        SumGroup(name: "table_\(index)", items: (1...index).map { .dummy($0) })
    }
}
