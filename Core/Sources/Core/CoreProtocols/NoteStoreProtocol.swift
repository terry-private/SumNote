import Foundation
import Entities
import Observation

@MainActor
public protocol NoteStoreProtocol: AnyObject {
    var notes: [SumNote] { get }
    var yearMonthSections: [SectionBox<YearMonth, SumNote>] { get }
    func note(by id: SumNote.ID) -> SumNote?
    @discardableResult
    func update(_ note: SumNote) -> Task<Void, Error>
    @discardableResult
    func update(_ group: SumGroup, in noteID: SumNote.ID) -> Task<Void, Error>
    @discardableResult
    func update(_ item: SumItem, in noteID: SumNote.ID) -> Task<Void, Error>
    @discardableResult
    func update(_ item: SumItem, in groupID: SumGroup.ID, in noteID: SumNote.ID) -> Task<Void, Error>
    @discardableResult
    func create(_ note: SumNote) -> Task<Void, Error>
    @discardableResult
    func delete(_ id: SumNote.ID) -> Task<Void, Error>
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
    public var _notes: [SumNote.ID: SumNote] = (1...20).lazy.map { _ in SumNote.dummy() }.reduce(into: [:]) { result, note in
        result[note.id] = note
    }
    public var notes: [SumNote] { _notes.values.lazy.sorted { $0.editedAt > $1.editedAt } }
    public func note(by id: SumNote.ID) -> SumNote? { _notes[id] }
    
    @discardableResult
    public func update(_ note: Entities.SumNote) -> Task<Void, any Error> {
        var note = note
        note.editedAt = Date()
        _notes[note.id] = note
        return .init {}
    }

    @discardableResult
    public func update(_ group: Entities.SumGroup, in noteID: Entities.SumNote.ID) -> Task<Void, any Error> {
        guard var note = _notes[noteID] else { return .init {} }
        note.groups[group.id] = group
        return update(note)
    }

    @discardableResult
    public func update(_ item: Entities.SumItem, in noteID: Entities.SumNote.ID) -> Task<Void, any Error> {
        guard var note = _notes[noteID] else { return .init {} }
        note.items[item.id] = item
        return update(note)
    }

    @discardableResult
    public func update(_ item: Entities.SumItem, in groupID: Entities.SumGroup.ID, in noteID: Entities.SumNote.ID) -> Task<Void, any Error> {
        guard var note = _notes[noteID] else { return .init {} }
        note.groups[groupID]?.items[item.id] = item
        return update(note)
    }

    @discardableResult
    public func create(_ note: Entities.SumNote) -> Task<Void, any Error> {
        _notes[note.id] = note
        return .init {}
    }

    @discardableResult
    public func delete(_ id: Entities.SumNote.ID) -> Task<Void, any Error> {
        _notes[id] = nil
        return .init {}
    }

}
