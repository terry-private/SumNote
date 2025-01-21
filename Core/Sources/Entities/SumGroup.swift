import Foundation
import BigInt
import Collections

public struct SumGroup: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var items: OrderedDictionary<SumItem.ID, SumItem>
    public init(id: ID = .ID(rawValue: UUID().uuidString), name: String, items: OrderedDictionary<SumItem.ID, SumItem>) {
        self.id = id
        self.name = name
        self.items = items
    }
    public init(id: ID = .ID(rawValue: UUID().uuidString), name: String, items: [SumItem]) {
        self.id = id
        self.name = name
        self.items = items.reduce(into: OrderedDictionary<SumItem.ID, SumItem>()) {
            $0[$1.id] = $1
        }
    }
    public func sum() -> BFraction {
        items.values.reduce(.ZERO) {
            $0 + $1.sum
        }
    }

    /// 数量の合計
    /// - Returns: 単位が全て同じなら数量の合計を返す。もし違う単位が混じっているならnilを返す。
    public func totalQuantity() -> (BFraction, String)? {
        guard let firstUnitName = items.values.first?.quantityUnitName else {
            return nil
        }

        var totalQuantity: BFraction = .ZERO

        for item in items.values {
            guard item.quantityUnitName == firstUnitName else {
                return nil
            }
            totalQuantity += item.quantity
        }

        return (totalQuantity, firstUnitName)
    }

    public func description(with indent: Int = 0, spaces: Int = 2) -> String {
        var rowTexts: [String] = [name.indent(indent, spaces: spaces)]
        for item in items.values {
            rowTexts.append(item.description(with: indent + 1))
        }
        rowTexts.append("合計 \(sum().ex.currencyString()) 円".indent(indent + 1))
        return rowTexts.joined(separator: "\n")
    }

}
