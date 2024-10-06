import Entities
import Foundation
import SwiftData
import CoreProtocols

public enum NoteRepository: NoteRepositoryProtocol {
    static let database: SwiftDatabase = {
        do {
            return .init(
                modelContainer: try .init(
                    for: NoteModel.self, TableModel.self,
                    storageType: .file()
                )
            )
        } catch {
            fatalError("can't create database: \(error.localizedDescription)")
        }
    }()
    public static func fetchAll() async throws -> [CalcNote] {
        try await database.fetch(FetchDescriptor<NoteModel>(sortBy: [.init(\.editedAt)]))
    }
    public static func fetch(by id: CalcNote.ID) async throws -> CalcNote? {
        try await database.fetch(
            FetchDescriptor<NoteModel>(predicate: #Predicate {
                $0.id == id.rawValue
            })
        ).first
    }
    public static func create(_ note: CalcNote) async throws {
        try await database.insert(note, as: NoteModel.self)
    }
    public static func update(note: CalcNote) async throws {
        try await database.update(note, as: NoteModel.self)
    }
    public static func delete(_ id: CalcNote.ID) async throws {
        try await database.delete(
            where: #Predicate { (model: NoteModel) -> Bool in
                model.id == id.rawValue
            }
        )
    }
    public static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) async throws {
//        if let model = (try context.fetch(
//            FetchDescriptor<NoteModel>(predicate: #Predicate {
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
            where: #Predicate { (model: TableModel) -> Bool in
                model.id == id.rawValue
            }
        )
    }
}