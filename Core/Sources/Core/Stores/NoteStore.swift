import Foundation
import Entities
import CoreProtocols
import Observation
import SwiftData

@Observable
@MainActor
public final class NoteStore<Repository: NoteRepositoryProtocol>: NoteStoreProtocol {
    public var notes: [SumNote] = []
    var refreshTask: Task<Void, Error>?
    public var isRefreshing: Bool { refreshTask != nil }
    public init() {
        refreshTask = Task {
            defer { refreshTask = nil }
            do {
                try await refresh()
            } catch {
                print(error)
            }
        }
    }
    public func update(_ note: SumNote) async throws {
        var note = note
        note.editedAt = Date()
        try await Repository.update(note: note)
        try await refresh()
    }
    public func delete(_ id: SumNote.ID) async throws {
        try await Repository.delete(id)
        try await refresh()
    }
    public func delete(_ id: SumGroup.ID, in noteID: SumNote.ID) async throws {
        try await Repository.delete(id, in: noteID)
        try await refresh()
    }
    public func note(by id: SumNote.ID) async throws -> SumNote? {
        try await Repository.fetch(by: id)
    }
    public func refresh() async throws {
        notes = try await Repository.fetchAll()
    }
    public func create(_ note: SumNote) async throws {
        try await Repository.create(note)
        try await refresh()
    }
    public var yearMonthSections: [SectionBox<YearMonth, SumNote>] {
        let ymToNotes: [YearMonth: [SumNote]] = notes
            .reduce(into: [:]) { result, note in
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


