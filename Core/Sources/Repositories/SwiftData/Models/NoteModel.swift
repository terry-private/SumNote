import struct Foundation.Date
import Entities
import SwiftData

@Model
public final class NoteModel {
    @Attribute(.unique) public let id: String
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

extension NoteModel {
    var entity: CalcNote {
        .init(
            id: .init(rawValue: id),
            name: name,
            tables: tables,
            editedAt: editedAt,
            createdAt: createdAt
        )
    }
}
