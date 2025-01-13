import Foundation
import Entities
import CoreProtocols
import Observation
import SwiftData
import Collections

@Observable
@MainActor
public final class NoteStore<Repository: NoteRepositoryProtocol>: NoteStoreProtocol {

    public var values: OrderedDictionary<SumNote.ID, SumNote> = [:]
    var refreshTask: Task<Void, Error>?

    public init() {
        refresh()
    }

    public var notes: [SumNote] { values.values.elements }

    public func note(by id: SumNote.ID) -> SumNote? {
        values[id]
    }

    // MARK: - update
    @discardableResult
    public func update(_ note: SumNote) -> Task<Void, Error> {
        var note = note
        note.editedAt = Date()
        values[note.id] = note
        return Task {
            try await Repository.update(note)
        }
    }

    @discardableResult
    public func update(_ group: Entities.SumGroup, in noteID: Entities.SumNote.ID) -> Task<Void, Error>{
        guard var note = values[noteID] else {
            return .init {}
        }
        note.groups[group.id] = group
        return update(note)
    }

    @discardableResult
    public func update(_ item: Entities.SumItem, in noteID: Entities.SumNote.ID) -> Task<Void, Error> {
        guard var note = values[noteID] else {
            return .init {}
        }
        note.items[item.id] = item
        return update(note)
    }

    @discardableResult
    public func update(_ item: Entities.SumItem, in groupID: Entities.SumGroup.ID, in noteID: Entities.SumNote.ID) -> Task<Void, Error> {
        guard var note = values[noteID] else {
            return .init {}
        }
        note.groups[groupID]?.items[item.id] = item
        return update(note)
    }

    // MARK: - delete
    @discardableResult
    public func delete(_ id: SumNote.ID) -> Task<Void, Error> {
        values.removeValue(forKey: id)
        return Task {
            try await Repository.delete(id)
        }
    }
    @discardableResult
    public func delete(_ id: SumGroup.ID, in noteID: SumNote.ID) -> Task<Void, Error> {
        values[noteID]?.groups.removeValue(forKey: id)
        return Task {
            try await Repository.delete(id, in: noteID)
        }
    }
    @discardableResult
    public func create(_ note: SumNote) -> Task<Void, Error> {
        values[note.id] = note
        return Task {
            try await Repository.create(note)
        }
    }
    public var yearMonthSections: [SectionBox<YearMonth, SumNote>] {
        let ymToNotes: [YearMonth: [SumNote]] = notes.reduce(into: [:]) { result, note in
                let yearMonth = YearMonth(date: note.editedAt)
                result[yearMonth, default: []].append(note)
            }
        return ymToNotes
            .keys
            .sorted { $0.id > $1.id }
            .compactMap { yearMonth in
                let notes = ymToNotes[yearMonth]?.sorted { $0.editedAt > $1.editedAt }
                guard let notes else { return nil }
                return SectionBox(header: yearMonth, items: notes)
            }
    }
}

internal extension NoteStore {
    var isRefreshing: Bool { refreshTask != nil }

    @discardableResult
    func refresh() -> Task<Void, Error> {
        Task {
            defer { refreshTask = nil }
            do {
                let notes = try await Repository.fetchAll()
                values = notes.reduce(into: OrderedDictionary<SumNote.ID, SumNote>()) { result, note in
                    result[note.id] = note
                }
            } catch {
                print(error)
                throw error
            }
        }
    }
}
