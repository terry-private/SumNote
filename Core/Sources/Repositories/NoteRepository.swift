import Entities
import Foundation
import SwiftData
import CoreProtocols

public enum NoteRepository: NoteRepositoryProtocol {
    static let database: SwiftDatabase = {
        do {
            return .init(
                modelContainer: try .init(
                    for: SumNoteModel.self, SumGroupModel.self,
                    storageType: .file()
                )
            )
        } catch {
            fatalError("can't create database: \(error.localizedDescription)")
        }
    }()
    public static func fetchAll() async throws -> [SumNote] {
        try await database.fetch(FetchDescriptor<SumNoteModel>(sortBy: [.init(\.editedAt)]))
    }
    public static func fetch(by id: SumNote.ID) async throws -> SumNote? {
        try await database.fetch(
            FetchDescriptor<SumNoteModel>(predicate: #Predicate {
                $0.id == id.rawValue
            })
        ).first
    }
    public static func create(_ note: SumNote) async throws {
        try await database.insert(note, as: SumNoteModel.self)
    }
    public static func update(note: SumNote) async throws {
        try await database.update(note, as: SumNoteModel.self)
    }
    public static func delete(_ id: SumNote.ID) async throws {
        try await database.delete(
            where: #Predicate { (model: SumNoteModel) -> Bool in
                model.id == id.rawValue
            }
        )
    }
    public static func delete(_ id: SumGroup.ID, in noteID: SumNote.ID) async throws {
//        if let model = (try context.fetch(
//            FetchDescriptor<SumNoteModel>(predicate: #Predicate {
//                $0.id == noteID.rawValue
//            })
//        )).first {
//            if let index = model.tables.firstIndex(where: {
//                $0.id.rawValue == id.rawValue
//            }) {
//                model.tables.remove(at: index)
//            }
//        }
        try await database.delete(
            where: #Predicate { (model: SumGroupModel) -> Bool in
                model.id == id.rawValue
            }
        )
    }
}
