import Foundation
import Entities
import CoreProtocols
import Observation
import Repositories
import SwiftData

@Observable
@MainActor
public final class NoteStore<Repository: NoteRepositoryProtocol>: NoteStoreProtocol {
    public var notes: [CalcNote] = []
    public init() {
        refresh()
    }
    public func update(_ note: CalcNote) {
        var note = note
        note.editedAt = Date()
        do {
            try Repository.update(note: note)
            refresh()
        } catch {
            print(error)
            refresh()
        }
    }
    public func delete(_ id: CalcNote.ID) {
        do {
            try Repository.delete(id)
            refresh()
        } catch {
            print(error)
            refresh()
        }
    }
    public func delete(_ id: CalcTable.ID, in noteID: CalcNote.ID) {
        do {
            try Repository.delete(id, in: noteID)
            refresh()
        } catch {
            print(error)
            refresh()
        }
    }
    public func note(by id: CalcNote.ID) -> CalcNote? {
        do {
            return try Repository.fetch(by: id)
        } catch {
            print(error)
            return nil
        }
    }
    public func refresh() {
        do {
            notes = try Repository.fetchAll()
        } catch {
            print(error)
        }
    }
    public var yearMonthSections: [SectionBox<YearMonth, CalcNote>] {
        let ymToNotes: [YearMonth: [CalcNote]] = notes
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


