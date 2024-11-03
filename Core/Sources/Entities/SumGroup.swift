import Foundation
import BigInt

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
