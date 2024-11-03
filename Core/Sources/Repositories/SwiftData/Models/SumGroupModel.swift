import struct Foundation.Date
import Entities
import SwiftData

@Model
final class SumGroupModel {
    @Attribute(.unique) var id: String
    var note: SumNoteModel?
    var name: String
    var rows: [SumItem]
    init(id: String, note: SumNoteModel? = nil, name: String, rows: [SumItem]) {
        self.id = id
        self.note = note
        self.name = name
        self.rows = rows
    }
}

extension SumGroupModel: EntityConvertible {
    convenience init (from entity: SumGroup) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            rows: entity.rows
        )
    }
    func update(from entity: SumGroup) {
        id = entity.id.rawValue
        name = entity.name
        rows = entity.rows
    }
    func toEntity() -> SumGroup {
        .init(
            id: .init(rawValue: id),
            name: name,
            rows: rows
        )
    }
}
