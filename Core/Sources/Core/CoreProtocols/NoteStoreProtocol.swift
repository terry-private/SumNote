import Foundation
import Entities
import Observation

@MainActor
public protocol NoteStoreProtocol: AnyObject {
    var notes: [SumNote] { get }
    var yearMonthSections: [SectionBox<YearMonth, SumNote>] { get }
    func note(by id: SumNote.ID) async throws -> SumNote?
    func update(_ note: SumNote) async throws
    func create(_ note: SumNote) async throws
    func delete(_ id: SumNote.ID) async throws
}

extension NoteStoreProtocol {
    public var yearMonthSections: [SectionBox<YearMonth, SumNote>] {
        let ymToNotes: [YearMonth: [SumNote]] = notes.lazy
            .reduce(into: [:]) { result, note in
                let yearMonth = YearMonth(date: note.editedAt)
                result[yearMonth, default: []].append(note)
            }
        return ymToNotes
            .keys
            .lazy
            .sorted { $0.id > $1.id }
            .compactMap { yearMonth in
                let notes = ymToNotes[yearMonth]?.sorted { $0.editedAt > $1.editedAt }
                guard let notes else { return nil }
                return SectionBox(header: yearMonth, items: notes)
            }
    }
}

@Observable
public final class DummyNoteStore: NoteStoreProtocol {
    public init() {}
    public var _notes: [SumNote.ID: SumNote] = (1...20).lazy.map { SumNote.dummy($0) }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public var notes: [SumNote] { _notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }
    public func note(by id: SumNote.ID) -> SumNote? { _notes[id] }
    public func update(_ note: SumNote) {
        var note = note
        note.editedAt = Date()
        _notes[note.id] = note
    }
    public func create(_ note: SumNote) {
        _notes[note.id] = note
    }
    public func delete(_ id: SumNote.ID) {
        _notes[id] = nil
    }
}
