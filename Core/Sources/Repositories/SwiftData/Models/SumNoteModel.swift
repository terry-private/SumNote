import struct Foundation.Date
import Entities
import SwiftData

@Model
final class SumNoteModel {
    @Attribute(.unique) var id: String
    var name: String
    var groups: [SumGroup]
    var editedAt: Date
    var createdAt: Date
    init(id: String, name: String, groups: [SumGroup], editedAt: Date, createdAt: Date) {
        self.id = id
        self.name = name
        self.groups = groups
        self.editedAt = editedAt
        self.createdAt = createdAt
    }
}

extension SumNoteModel: EntityConvertible {
    convenience init(from entity: SumNote) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            groups: entity.groups,
            editedAt: entity.editedAt,
            createdAt: entity.createdAt
        )
    }
    func update(from entity: SumNote) {
        self.id = entity.id.rawValue
        self.name = entity.name
        self.groups = entity.groups
        self.editedAt = entity.editedAt
        self.createdAt = entity.createdAt
    }
    func toEntity() -> SumNote {
        .init(
            id: .init(rawValue: id),
            name: name,
            groups: groups,
            editedAt: editedAt,
            createdAt: createdAt
        )
    }
}
