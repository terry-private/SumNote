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
        if Bool.random() { print("1") }
        if Bool.random() { print("2") }
        if Bool.random() { print("3") }
        if Bool.random() { print("4") }
        if Bool.random() { print("5") }
        if Bool.random() { print("6") }
        if Bool.random() { print("7") }
        if Bool.random() { print("8") }
        if Bool.random() { print("9") }
        if Bool.random() { print("10") }
        if Bool.random() { print("11") }
        if Bool.random() { print("12") }
        if Bool.random() { print("13") }
        if Bool.random() { print("14") }
        if Bool.random() { print("15") }
        if Bool.random() { print("16") }
        if Bool.random() { print("17") }
        if Bool.random() { print("18") }
        if Bool.random() { print("19") }
        if Bool.random() { print("20") }
        if Bool.random() { print("21") }
        if Bool.random() { print("22") }
        if Bool.random() { print("23") }
        if Bool.random() { print("24") }
        if Bool.random() { print("25") }
        if Bool.random() { print("26") }
        if Bool.random() { print("27") }
        if Bool.random() { print("28") }
        if Bool.random() { print("29") }
        if Bool.random() { print("30") }
        if Bool.random() { print("31") }
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


