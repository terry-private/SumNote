import SwiftUI
import Entities
import CoreProtocols

public struct FolderListView<Dependency: DependencyProtocol>: View {
//    @State var sections: [SectionBox<YearMonth, Folder>]
    @State var selected: Folder?
    @State var store = Dependency.folderStore
    public init() {
    }
    public var body: some View {
        List(store.yearMonthSections) { section in
            Section(header: Text(section.header.title)) {
                ForEach(section.items) { folder in
                    Button {
                        selected = folder
                    } label: {
                        Text("\(folder.id.rawValue): \(folder.name)")
                    }
                }
            }
        }
        .navigationDestination(
            item: $selected,
            destination: { folder in
                VStack(alignment: .leading) {
                    Text("id: \(folder.id.rawValue)")
                    Text("name: \(folder.name)")
                }
                .navigationTitle(folder.name)
            }
        )
        .navigationTitle("フォルダ")
    }
}

#Preview {
    NavigationStack {
        FolderListView<DummyDependency>()
    }
}
