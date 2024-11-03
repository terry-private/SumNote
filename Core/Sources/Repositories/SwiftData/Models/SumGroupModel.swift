import struct Foundation.Date
import Entities
import SwiftData

@Model
final class SumGroupModel {
    @Attribute(.unique) var id: String
    var note: SumNoteModel?
    var name: String
    var items: [SumItem]
    init(id: String, note: SumNoteModel? = nil, name: String, items: [SumItem]) {
        self.id = id
        self.note = note
        self.name = name
        self.items = items
    }
}

extension SumGroupModel: EntityConvertible {
    convenience init (from entity: SumGroup) {
        self.init(
            id: entity.id.rawValue,
            name: entity.name,
            items: entity.items
        )
    }
    func update(from entity: SumGroup) {
        id = entity.id.rawValue
        name = entity.name
        items = entity.items
    }
    func toEntity() -> SumGroup {
        .init(
            id: .init(rawValue: id),
            name: name,
            items: items
        )
    }
}
