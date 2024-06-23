import Foundation
import SwiftID

@StringIdentifiable(String.self)
public struct Folder: Sendable, Hashable, Codable, Equatable {
    public var name: String
    public var notes: [CalcNote]
    public var editedAt: Date
    public init(id: ID = .init(rawValue: UUID().uuidString), name: String, notes: [CalcNote], editedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.notes = notes
        self.editedAt = editedAt
    }
}

public extension Folder {
    static func dummy(_ index: Int) -> Self {
        Folder(name: "folder_\(index)", notes: (1...index).map { .dummy($0) }, editedAt: .dummy)
    }
}
