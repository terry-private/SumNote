import Entities
import Foundation
import SwiftData

@MainActor
public protocol NoteRepositoryProtocol {
    static func fetchAll() throws -> [CalcNote]
    static func fetch(by id: CalcNote.ID) throws -> CalcNote?
    static func create(_ note: CalcNote) throws
    static func update(note: CalcNote) throws
    static func delete(_ id: CalcNote.ID) throws
    static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) throws
}

public enum NoteRepository: NoteRepositoryProtocol {
    static let context: ModelContext = {
        do {
            return try ModelContext(
                for: NoteModel.self, TableModel.self,
                storageType: .file
            )
        } catch {
            fatalError()
        }
    }()

    public static func fetchAll() throws -> [CalcNote] {
        let notes = try context.fetch(FetchDescriptor<NoteModel>(sortBy: [.init(\.editedAt)]))
        return notes.map { $0.entity }
    }
    public static func fetch(by id: CalcNote.ID) throws -> CalcNote? {
        let note = try context.fetch(
            FetchDescriptor<NoteModel>(predicate: #Predicate {
                $0.id == id.rawValue
            })
        ).first
        return note?.entity
    }
    public static func create(_ note: CalcNote) throws {
        let model = NoteModel(
            id: note.id.rawValue,
            name: note.name,
            tables: note.tables,
            editedAt: note.editedAt,
            createdAt: note.createdAt
        )
        context.insert(model)
    }
    public static func create(_ table: CalcTable, in note: NoteModel? = nil) throws {
        let model = TableModel(
            id: table.id.rawValue,
            note: note,
            name: table.name,
            rows: table.rows
        )
        context.insert(model)
    }
    public static func update(note: CalcNote) throws {
        if let model = (try context.fetch(
            FetchDescriptor<NoteModel>(predicate: #Predicate {
                $0.id == note.id.rawValue
            })
        )).first {
            model.name = note.name
            model.tables = note.tables
            model.editedAt = note.editedAt
            model.createdAt = note.createdAt
//            note.tables.forEach { table in
//                if let tableModel = model.tables.first(where: { tableModel in
//                    table.id.rawValue == tableModel.id
//                }) {
//                    tableModel.name = table.name
//                    tableModel.rows = table.rows
//                } else {
//
//                }
////                try update(table: table, in: model)
//            }
        } else {
            try create(note)
        }
    }
    public static func update(table: CalcTable, in note: NoteModel? = nil) throws {
        if let model = (try context.fetch(
            FetchDescriptor<TableModel>(predicate: #Predicate {
                $0.id == table.id.rawValue
            })
        )).first {
            model.name = table.name
            model.rows = table.rows
        } else {
            try create(table, in: note)
        }
    }
    public static func delete(_ id: CalcNote.ID) throws {
        try context.delete(
            model: NoteModel.self,
            where: #Predicate {
                $0.id == id.rawValue
            }
        )
    }
    public static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) throws {
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
        try context.delete(
            model: TableModel.self,
            where: #Predicate {
                $0.id == id.rawValue
            }
        )
    }
}

/// ダミー
public enum DummyNoteRepository: NoteRepositoryProtocol {
    
    static var notes: [CalcNote.ID: CalcNote] = (1...20).lazy.map { _ in CalcNote.dummy() }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public static func fetchAll() throws -> [CalcNote] { notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }

    public static func fetch(by id: CalcNote.ID) throws -> CalcNote? { notes[id] }

    public static func create(_ note: CalcNote) throws { notes[note.id] = note }

    public static func update(note: CalcNote) throws { notes[note.id] = note }

    public static func delete(_ id: CalcNote.ID) throws { notes[id] = nil }
    public static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) throws { }
}
