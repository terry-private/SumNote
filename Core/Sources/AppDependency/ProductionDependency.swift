import CoreProtocols
import NoteListFeature
import NoteFeature
import SwiftUI
import Entities
import Repositories
import Stores

public enum ProductionDependency: DependencyProtocol {
    @MainActor public static func rootView() -> some View {
        NavigationStack {
            noteListView()
        }
    }
    @MainActor public static func noteListView() -> NoteListView<Self> {
        NoteListFeature.NoteListView<Self>()
    }
    @MainActor public static func noteView(_ noteID: SumNote.ID) -> some View {
        NoteFeature.NoteView<Self>(noteID)
    }
    // MARK: - Stores
    @MainActor public static let noteStore = Stores.NoteStore<NoteRepository>()
    // MARK: - Repositories
    public typealias NoteRepository = Repositories.NoteRepository
}
