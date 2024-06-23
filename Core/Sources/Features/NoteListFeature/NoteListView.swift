import SwiftUI
import Entities
import CoreProtocols

public struct NoteListView<Dependency: DependencyProtocol>: View {
    @State var store = Dependency.noteStore
    @State var selected: CalcNote?
    public init() {}
    public var body: some View {
        List(store.yearMonthSections) { section in
            Section(header: Text(section.header.title)) {
                ForEach(section.items) { note in
                    Button {
                        selected = note
                    } label: {
                        Text("\(note.name)")
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        store.delete(section.items[$0].id)
                    }
                }
            }
        }
        .navigationDestination(
            item: $selected,
            destination: { note in
                Dependency.noteView(note: note)
                    .navigationTitle(note.name)
            }
        )
        .navigationTitle("ノートリスト")
    }
}

#Preview {
    NavigationStack {
        NoteListView<DummyDependency>()
    }
}
