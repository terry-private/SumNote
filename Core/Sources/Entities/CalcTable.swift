import Foundation
import BigInt

public struct CalcTable: Sendable, Hashable, Codable, Equatable, Identifiable {
    public struct ID: StringIDProtocol {
        public var rawValue: String
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    public let id: ID
    public var name: String
    public var rows: [CalcRow]
    public var sum: BFraction {
        rows.reduce(.ZERO) {
            $0 + $1.sum
        }
    }

    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, rows: [CalcRow]) {
        self.id = id
        self.name = name
        self.rows = rows
    }
}

extension CalcTable: CustomStringConvertible {
    public var description: String {
        """
        \(name)
         \(rows.flatMap {
            $0.description.split(separator: "\n")
            }.joined(separator: "\n ")
        )
        合計 \(sum.currency) 円
        """
    }
}
public extension CalcTable {
    static func dummy(_ index: Int) -> Self {
        CalcTable(name: "table_\(index)", rows: (1...index).map { .dummy($0) })
    }
}
