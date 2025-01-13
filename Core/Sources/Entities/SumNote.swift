import Foundation
import BigIntExtensions
import Collections

public struct SumNote: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var groups: OrderedDictionary<SumGroup.ID, SumGroup>
    public var items: OrderedDictionary<SumItem.ID, SumItem>
    public var editedAt: Date
    public var createdAt: Date
    public func sum() -> BFraction {
        items.values.reduce(BFraction.ZERO) { $0 + $1.sum } + groups.values.reduce(BFraction.ZERO) { $0 + $1.sum() }
    }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, groups: OrderedDictionary<SumGroup.ID, SumGroup>, items: OrderedDictionary<SumItem.ID, SumItem>, editedAt: Date, createdAt: Date) {
        self.id = id
        self.name = name
        self.groups = groups
        self.items = items
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, groups: [SumGroup], items: [SumItem], editedAt: Date, createdAt: Date) {
        self.id = id
        self.name = name
        self.groups = groups.reduce(into: OrderedDictionary()) { $0[$1.id] = $1 }
        self.items = items.reduce(into: OrderedDictionary()) { $0[$1.id] = $1 }
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
    public func description() -> String {
        var rowTexts: [String] = [name]
        for group in groups.values {
            rowTexts.append(group.description(with: 1))
        }
        rowTexts += items.values.map { $0.description(with: 1) }
        rowTexts.append("総計 \(sum().ex.currencyString()) 円".indent(1))
        return rowTexts.joined(separator: "\n")
    }
    public static func dummy() -> SumNote {
        SumNote(
            name: "BBQ",
            groups: [
                .init(
                    name: "肉類🍖",
                    items: [
                        .init(
                            name: "カルビ",
                            unitPrice: .init(2885, 1000),
                            quantity: .init(866,1),
                            unitName: "g",
                            option: .init(style: .percentile,15)
                        ),
                        .init(
                            name: "ロース",
                            unitPrice: .init(29874, 1000),
                            quantity: .init(841,1),
                            unitName: "g",
                            option: .dummy(3)
                        ),
                        .init(
                            name: "鶏肉",
                            unitPrice: .init(96,100),
                            quantity: .init(400,1),
                            unitName: "g",
                            option: .dummy(1)
                        ),
                        .init(
                            name: "豚肉",
                            unitPrice: .init(96,100),
                            quantity: .init(400,1),
                            unitName: "g",
                            option: .dummy(1)
                        )
                    ]
                ),
                .init(
                    name: "飲み物",
                    items: [
                        .init(
                            name: "ビール 350ml",
                            unitPrice: .init(198,1),
                            quantity: .init(24,1),
                            unitName: "缶",
                            option: .dummy(3)
                        ),
                        .init(
                            name: "ビール 500ml",
                            unitPrice: .init(298,1),
                            quantity: .init(24,1),
                            unitName: "缶",
                            option: .dummy(3)
                        ),
                        .init(
                            name: "ハイボール",
                            unitPrice: .init(198,1),
                            quantity: .init(24,1),
                            unitName: "缶",
                            option: .dummy(3)
                        ),
                        .init(name: "水 2l", unitPrice: .init(100, 1), quantity: .init(3, 1), unitName: "本")
                    ]
                )
            ],
            items: [
                .init(name: "割り箸", unitPrice: .init(100, 1), quantity: .init(1, 1), unitName: "袋", option: .dummy(1)),
                .init(name: "ゴミ袋", unitPrice: .init(130, 1), quantity: .init(1, 1), unitName: "ケース"),
                .init(name: "箱ティッシュ", unitPrice: .init(350, 1), quantity: .init(1, 1), unitName: "ケース")

            ],
            editedAt: .dummy,
            createdAt: .dummy
        )
    }
}
