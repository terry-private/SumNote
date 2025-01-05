import Foundation
import BigIntExtensions

public struct SumNote2: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var rows: [SumRow]
    public var editedAt: Date
    public var createdAt: Date
    public func sum() -> BFraction {
        rows.reduce(BFraction.ZERO) { $0 + $1.sum() }
    }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, rows: [SumRow], editedAt: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.rows = rows
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}
public extension SumNote2 {
    func description() -> String {
        var rowTexts: [String] = [name]
        for row in rows {
            rowTexts.append(row.description(with: 1))
        }
        rowTexts.append("総計 \(sum().ex.currencyString()) 円".indent(1))
        return rowTexts.joined(separator: "\n")
    }
    static func dummy(_ index: Int) -> Self {
        .init(
            name: "note_\(index)",
            rows: (1...index).map { SumRow.dummy($0) },
            editedAt: .dummy)
    }
    static func dummy() -> Self {
        SumNote2(
            name: "BBQ",
            rows: [
                .group(
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
                                name: "ウインナー",
                                unitPrice: .init(96,100),
                                quantity: .init(400,1),
                                unitName: "g",
                                option: .dummy(1)
                            )
                        ]
                    )
                ),
                .group(
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
                            .init(name: "水 2l", unitPrice: .init(100, 1), quantity: .init(3, 1), unitName: "本")
                        ]
                    )
                ),
                .item(
                    .init(name: "割り箸", unitPrice: .init(100, 1), quantity: .init(1, 1), unitName: "袋", option: .dummy(1))
                ),
                .item(
                    .init(name: "ゴミ袋", unitPrice: .init(130, 1), quantity: .init(1, 1), unitName: "ケース")
                )
                ],
            editedAt: .dummy,
            createdAt: .dummy
        )
    }
}

public struct SumNote: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var groups: [SumGroup]
    public var editedAt: Date
    public var createdAt: Date
    public var sum: BFraction { groups.reduce(.ZERO) { $0+$1.sum } }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, groups: [SumGroup], editedAt: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.groups = groups
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}

public extension SumNote {
    func description() -> String {
        var texts: [String] = [name]
        texts += groups.map {
            $0.description(with: 1)
        }
        texts.append("総計: \(sum.ex.currencyString()) 円")
        return texts.joined(separator: "\n")
    }
    static func dummy(_ index: Int) -> Self {
        SumNote(name: "note_\(index)", groups: (1...index).map { .dummy($0) }, editedAt: .dummy)
    }
    static func dummy() -> Self {
        SumNote(
            name: "BBQ",
            groups: [
                .init(name: "肉類🍖", items: [
                    .init(name: "カルビ", unitPrice: .init(2885, 1000), quantity: .init(866,1), unitName: "g", option: .dummy(3)),
                    .init(name: "ロース", unitPrice: .init(29874, 10000), quantity: .init(841,1), unitName: "g"),
                    .init(name: "ウインナー (10本入)", unitPrice: .init(480,1), quantity: .init(4,1), unitName: "袋")
                ]),
                .init(name: "飲み物", items: [
                    .init(name: "ビール 350ml", unitPrice: .init(198,1), quantity: .init(24,1), unitName: "缶"),
                    .init(name: "水 2l", unitPrice: .init(100, 1), quantity: .init(3, 1), unitName: "本")
                ])
            ],
            editedAt: .dummy,
            createdAt: .dummy
        )
    }
}
