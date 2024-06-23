import CoreProtocols
import FolderListFeature
import NoteListFeature
import NoteFeature
import SwiftUI
import Entities
import Stores

public enum ProductionDependency: DependencyProtocol {
    public static func rootView() -> some View {
        NavigationStack {
            noteListView()
        }
    }
    @MainActor public static func folderListView() -> FolderListView<Self> {
        FolderListFeature.FolderListView<Self>()
    }
    @MainActor public static func noteListView() -> NoteListView<Self> {
        NoteListFeature.NoteListView<Self>()
    }
    @MainActor public static func noteView(note: CalcNote) -> some View {
        NoteFeature.NoteView<Self>(note: note)
    }
    // MARK: - Stores
    @MainActor public static let folderStore = Stores.FolderStore()
    @MainActor public static let noteStore = Stores.NoteStore()
}
