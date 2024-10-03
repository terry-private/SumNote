import Entities
import SwiftData

protocol EntityConvertible where Self: PersistentModel, ID == Entity.ID.RawValue {
    associatedtype Entity: EntityProtocol
    init (from entity: Entity)
    func update(from entity: Entity)
    func toEntity() -> Entity
}
