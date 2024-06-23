import Foundation
import Entities
import CoreProtocols
import Observation
import SwiftData

@Observable
public final class NoteStore: NoteStoreProtocol {
    public init() {}
    public var _notes: [CalcNote.ID: CalcNote] = (1...20).lazy.map { _ in CalcNote.dummy() }.reduce(into: [:]) { result, note in
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
