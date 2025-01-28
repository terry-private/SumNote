import SwiftUI
import Entities

public protocol DependencyProtocol {
    
    // MARK: - View
    associatedtype RootView: View
    @MainActor static func rootView() -> RootView

    associatedtype MainTabView: View
    @MainActor static func mainTabView() -> MainTabView

    associatedtype NoteListView: View
    @MainActor static func noteListView() -> NoteListView
    
    associatedtype NoteView: View
    @MainActor static func noteView(_ noteID: SumNote.ID) -> NoteView

    // MARK: - Stores
    associatedtype NoteStore: NoteStoreProtocol
    @MainActor static var noteStore: NoteStore { get }

    // MARK: - Repositories
    associatedtype NoteRepository: NoteRepositoryProtocol
}

public enum DummyDependency: DependencyProtocol {
    public static func rootView() -> some View { Text("RootView") }
    public static func mainTabView() -> some View { Text("MainTabView") }
    public static func noteListView() -> some View { Text("NoteListView") }
    public static func noteView(_ noteID: SumNote.ID) -> some View { Text("NoteView") }
    public static var noteStore = DummyNoteStore()
    public typealias NoteRepository = DummyNoteRepository
}
