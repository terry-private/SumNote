import struct Foundation.Date
import Entities
import SwiftData

@Model
public final class TableModel {
    @Attribute(.unique) public var id: String
    public var note: NoteModel?
    public var name: String
    public var rows: [CalcRow]
    public init(id: String, note: NoteModel? = nil, name: String, rows: [CalcRow]) {
        self.id = id
        self.note = note
        self.name = name
        self.rows = rows
    }
}

extension TableModel: EntityConvertible {
    public convenience init (from entity: CalcTable) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            rows: entity.rows
        )
    }
    public func update(from entity: CalcTable) {
        id = entity.id.rawValue
        name = entity.name
        rows = entity.rows
    }
    public func toEntity() -> CalcTable {
        .init(
            id: .init(rawValue: id),
            name: name,
            rows: rows
        )
    }
}
