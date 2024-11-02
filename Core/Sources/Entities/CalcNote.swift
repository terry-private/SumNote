import Foundation
import BigIntExtensions

public struct CalcNote: EntityProtocol {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var tables: [CalcTable]
    public var editedAt: Date
    public var createdAt: Date
    public var sum: BFraction { tables.reduce(.ZERO) { $0+$1.sum } }
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, tables: [CalcTable], editedAt: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tables = tables
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}

public extension CalcNote {
    func description() -> String {
        var texts: [String] = [name]
        texts += tables.map {
            $0.description(with: 1)
        }
        texts.append("総計: \(sum.ex.currencyString()) 円")
        return texts.joined(separator: "\n")
    }
    static func dummy(_ index: Int) -> Self {
        CalcNote(name: "note_\(index)", tables: (1...index).map { .dummy($0) }, editedAt: .dummy)
    }
    static func dummy() -> Self {
        CalcNote(
            name: "BBQ",
            tables: [
                .init(name: "肉類🍖", rows: [
                    .init(name: "カルビ", unitPrice: .init(2885, 1000), quantity: .init(866,1), unitName: "g", options: [.dummy(3)]),
                    .init(name: "ロース", unitPrice: .init(29874, 10000), quantity: .init(841,1), unitName: "g"),
                    .init(name: "ウインナー (10本入)", unitPrice: .init(480,1), quantity: .init(4,1), unitName: "袋")
                ]),
                .init(name: "飲み物", rows: [
                    .init(name: "ビール 350ml", unitPrice: .init(198,1), quantity: .init(24,1), unitName: "缶"),
                    .init(name: "水 2l", unitPrice: .init(100, 1), quantity: .init(3, 1), unitName: "本")
                ])
            ],
            editedAt: .dummy,
            createdAt: .dummy
        )
    }
}
