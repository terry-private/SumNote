import Entities

public protocol NoteRepositoryProtocol {
    static func fetchAll() async throws -> [CalcNote]
    static func fetch(by id: CalcNote.ID) async throws -> CalcNote?
    static func create(_ note: CalcNote) async throws
    static func update(note: CalcNote) async throws
    static func delete(_ id: CalcNote.ID) async throws
    static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) async throws
}

/// ダミー
public enum DummyNoteRepository: NoteRepositoryProtocol {
    // FIXME: nonisolated
    nonisolated(unsafe) static var notes: [CalcNote.ID: CalcNote] = (1...20).lazy.map { _ in CalcNote.dummy() }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public static func fetchAll() throws -> [CalcNote] { notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }

    public static func fetch(by id: CalcNote.ID) throws -> CalcNote? { notes[id] }

    public static func create(_ note: CalcNote) throws { notes[note.id] = note }

    public static func update(note: CalcNote) throws { notes[note.id] = note }

    public static func delete(_ id: CalcNote.ID) throws { notes[id] = nil }
    public static func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) throws { }
}
