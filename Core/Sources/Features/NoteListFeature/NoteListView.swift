import SwiftUI
import Components
import Entities
import CoreProtocols
import Stores

public struct NoteListView<Dependency: DependencyProtocol>: View {
    @State var store = Dependency.noteStore
    @State var selected: SumNote?
    @State var removingNote: SumNote?
    public init() {}
    public var body: some View {
        List(store.yearMonthSections) { section in
            Section(header: Text(section.header.title)) {
                ForEach(section.items) { note in
                    Button {
                        selected = note
                    } label: {
                        HStack {
                            Image(systemName: "note.text")
                            VStack(alignment: .leading) {
                                Text("\(note.name)")
                                    .tint(.primary)
                                Text(DateString.humanize(note.editedAt))
                                    .font(.caption)
                                    .tint(.secondary)
                            }
                            Spacer()
                            note.sum().text()
                                .add(prefix: "総額", suffix: "円")
                                .tint(.secondary)
                        }
                    }
                    .listRowBackground(removingNote?.id == note.id ? Color(uiColor: .systemFill) : nil)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            removingNote = note
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .alert(
            "ノートの削除",
            isPresented: .init(from: $removingNote),
            presenting: removingNote
        ) { note in
            Button("キャンセル", role: .cancel) {

            }
            Button("削除", role: .destructive) {
                withAnimation {
                    _ = store.delete(note.id)
                }
            }
        } message: { note in
            Text("\(note.name)を削除しますか？")
        }
        .navigationDestination(
            item: $selected,
            destination: { note in
                Dependency.noteView(note.id)
            }
        )
        .navigationTitle("ノートリスト")
        .toolbar {
            Menu {
                Button("新規作成", systemImage: "doc.badge.plus") {
                    store.create(.dummy())
                }
                Button("テンプレートから作成", systemImage: "tray.and.arrow.up") {
                    store.create(.dummy())
                }
            } label: {
                Label("add", systemImage: "square.and.pencil")
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteListView<DummyDependency>()
    }
}
