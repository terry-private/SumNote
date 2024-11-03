import SwiftUI
import Entities

public protocol DependencyProtocol {
    
    // MARK: - View
    associatedtype RootView: View
    @MainActor static func rootView() -> RootView
    
    associatedtype FolderListView: View
    @MainActor static func folderListView() -> FolderListView
    
    associatedtype NoteListView: View
    @MainActor static func noteListView() -> NoteListView
    
    associatedtype NoteView: View
    @MainActor static func noteView(note: SumNote) -> NoteView
    
    // MARK: - Stores
    associatedtype FolderStore: FolderStoreProtocol
    @MainActor static var folderStore: FolderStore { get }
    
    associatedtype NoteStore: NoteStoreProtocol
    @MainActor static var noteStore: NoteStore { get }

    // MARK: - Repositories
    associatedtype NoteRepository: NoteRepositoryProtocol
}

public enum DummyDependency: DependencyProtocol {
    public static func rootView() -> some View { EmptyView() }
    public static func folderListView() -> some View { EmptyView() }
    public static func noteListView() -> some View { EmptyView() }
    public static func noteView(note: SumNote) -> some View { EmptyView() }
    public static var folderStore = DummyFolderStore()
    public static var noteStore = DummyNoteStore()
    public typealias NoteRepository = DummyNoteRepository
}
