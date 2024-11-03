import Entities

public protocol NoteRepositoryProtocol {
    static func fetchAll() async throws -> [SumNote]
    static func fetch(by id: SumNote.ID) async throws -> SumNote?
    static func create(_ note: SumNote) async throws
    static func update(note: SumNote) async throws
    static func delete(_ id: SumNote.ID) async throws
    static func delete(_ id: CalcTable.ID, in noteID: SumNote.ID) async throws
}

/// ダミー
public enum DummyNoteRepository: NoteRepositoryProtocol {
    // FIXME: nonisolated
    nonisolated(unsafe) static var notes: [SumNote.ID: SumNote] = (1...20).lazy.map { _ in SumNote.dummy() }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public static func fetchAll() throws -> [SumNote] { notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }

    public static func fetch(by id: SumNote.ID) throws -> SumNote? { notes[id] }

    public static func create(_ note: SumNote) throws { notes[note.id] = note }

    public static func update(note: SumNote) throws { notes[note.id] = note }

    public static func delete(_ id: SumNote.ID) throws { notes[id] = nil }
    public static func delete(_ id: CalcTable.ID, in noteID: SumNote.ID) throws { }
}
