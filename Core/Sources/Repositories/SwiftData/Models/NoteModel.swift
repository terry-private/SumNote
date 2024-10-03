import struct Foundation.Date
import Entities
import SwiftData

@Model
public final class NoteModel {
    @Attribute(.unique) public var id: String
    public var name: String
    public var tables: [CalcTable]
    public var editedAt: Date
    public var createdAt: Date
    public init(id: String, name: String, tables: [CalcTable], editedAt: Date, createdAt: Date) {
        self.id = id
        self.name = name
        self.tables = tables
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}

extension NoteModel: EntityConvertible {
    public convenience init(from entity: CalcNote) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            tables: entity.tables,
            editedAt: entity.editedAt,
            createdAt: entity.createdAt
        )
    }
    public func update(from entity: CalcNote) {
        self.id = entity.id.rawValue
        self.name = entity.name
        self.tables = entity.tables
        self.editedAt = entity.editedAt
        self.createdAt = entity.createdAt
    }
    public func toEntity() -> CalcNote {
        .init(
            id: .init(rawValue: id),
            name: name,
            tables: tables,
            editedAt: editedAt,
            createdAt: createdAt
        )
    }
}
