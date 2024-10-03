import Foundation
import Entities
import Observation

@MainActor
public protocol NoteStoreProtocol: AnyObject {
    var notes: [CalcNote] { get }
    var yearMonthSections: [SectionBox<YearMonth, CalcNote>] { get }
    func note(by id: CalcNote.ID) async throws -> CalcNote?
    func update(_ note: CalcNote) async throws
    func delete(_ id: CalcNote.ID) async throws
}

extension NoteStoreProtocol {
    public var yearMonthSections: [SectionBox<YearMonth, CalcNote>] {
        let ymToNotes: [YearMonth: [CalcNote]] = notes.lazy
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
    public var _notes: [CalcNote.ID: CalcNote] = (1...20).lazy.map { CalcNote.dummy($0) }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public var notes: [CalcNote] { _notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }
    public func note(by id: CalcNote.ID) -> CalcNote? { _notes[id] }
    public func update(_ note: CalcNote) {
        var note = note
        note.editedAt = Date()
        _notes[note.id] = note
    }
    public func delete(_ id: CalcNote.ID) {
        _notes[id] = nil
    }
}
