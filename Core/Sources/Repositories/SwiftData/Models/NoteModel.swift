import struct Foundation.Date
import Entities
import SwiftData

@Model
final class NoteModel {
    @Attribute(.unique) var id: String
    var name: String
    var tables: [CalcTable]
    var editedAt: Date
    var createdAt: Date
    init(id: String, name: String, tables: [CalcTable], editedAt: Date, createdAt: Date) {
        self.id = id
        self.name = name
        self.tables = tables
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}

extension NoteModel: EntityConvertible {
    convenience init(from entity: CalcNote) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            tables: entity.tables,
            editedAt: entity.editedAt,
            createdAt: entity.createdAt
        )
    }
    func update(from entity: CalcNote) {
        self.id = entity.id.rawValue
        self.name = entity.name
        self.tables = entity.tables
        self.editedAt = entity.editedAt
        self.createdAt = entity.createdAt
    }
    func toEntity() -> CalcNote {
        .init(
            id: .init(rawValue: id),
            name: name,
            tables: tables,
            editedAt: editedAt,
            createdAt: createdAt
        )
    }
}