import Foundation
import SwiftData

@ModelActor
public actor SwiftDatabase {
    public func delete<T: PersistentModel>(
        where predicate: Predicate<T>?
    ) throws {
        try modelContext.delete(model: T.self, where: predicate)
    }

    func insert<Model: PersistentModel>(_ entity: Model.Entity, as model: Model.Type) async where Model: EntityConvertible {
        let model = Model(from: entity)
        modelContext.insert(model)
    }

    public func save() throws {
        try modelContext.save()
    }

    public func fetch<T: EntityConvertible>(
        _ descriptor: FetchDescriptor<T>
    ) async throws -> [T.Entity] {
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toEntity() }
    }

    public func update<Model: PersistentModel>(
        _ entity: Model.Entity,
        as model: Model.Type
    ) async throws where Model: EntityConvertible {
        let descriptor = FetchDescriptor<Model>(predicate: #Predicate { $0.id == entity.id.rawValue  } )
        let models = try modelContext.fetch(descriptor)
        guard let model = models.first else {
            let model: Model = .init(from: entity)
            modelContext.insert(model)
            return
        }
        model.update(from: entity)
        try save()
    }
}
