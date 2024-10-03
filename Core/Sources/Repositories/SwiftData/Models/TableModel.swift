import struct Foundation.Date
import Entities
import SwiftData

@Model
final class TableModel {
    @Attribute(.unique) var id: String
    var note: NoteModel?
    var name: String
    var rows: [CalcRow]
    init(id: String, note: NoteModel? = nil, name: String, rows: [CalcRow]) {
        self.id = id
        self.note = note
        self.name = name
        self.rows = rows
    }
}

extension TableModel: EntityConvertible {
    convenience init (from entity: CalcTable) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            rows: entity.rows
        )
    }
    func update(from entity: CalcTable) {
        id = entity.id.rawValue
        name = entity.name
        rows = entity.rows
    }
    func toEntity() -> CalcTable {
        .init(
            id: .init(rawValue: id),
            name: name,
            rows: rows
        )
    }
}
