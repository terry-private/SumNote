import SwiftUI
import Components
import Entities
import CoreProtocols
import Stores

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
                    Task {
                        for index in indexSet {
                            try await store.delete(section.items[index].id)
                        }
                    }
                }
            }
        }
        .navigationDestination(
            item: $selected,
            destination: { note in
                Dependency.noteView(note: note)
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
