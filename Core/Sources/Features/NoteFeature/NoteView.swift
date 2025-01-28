import SwiftUI
import BigIntExtensions
import Entities
import CoreProtocols
import Components
import Combine
import Stores
import Collections

public struct NoteView<Dependency: DependencyProtocol>: View {
    @State var store = Dependency.noteStore
    let noteID: SumNote.ID
    @State var screenState: ScreenState?
    @State var scrollTargetItem: SumItem.ID?
    @State var scrollTargetGroup: SumGroup.ID?
    public init(_ noteID: SumNote.ID) {
        self.noteID = noteID
    }
    public var body: some View {
        if let note = store.note(by: noteID) {
            ScrollViewReader { scrollProxy in
                List {
                    Section {
                        groups(note)
                        items(note)
                        Color.clear.frame(height: 44)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        // MARK: - 総計 -
                        HStack {
                            Spacer()
                            HStack(alignment: .lastTextBaseline) {
                                Text("総計")
                                BFractionText(fraction: note.sum(), textStyle: .title)
                                    .foregroundStyle(Color(uiColor: .label))
                                Text("円")
                            }
                            .font(.headline)
                            .padding(5)
                            Spacer()
                        }
                    }

                }
                .listStyle(.plain)
                .onChange(of: scrollTargetItem) { _, newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue)
                    } completion: {
                        scrollTargetItem = nil
                    }
                }
                .onChange(of: scrollTargetGroup) { _, newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Menu {
                        Menu("商品") {
                            Button("テンプレートから作成", systemImage: "tray.and.arrow.up") {
                            }
                            Button("新規作成", systemImage: "doc.badge.plus") {
                                let item = SumItem(name: "", unitPrice: 0, quantity: 1, unitName: "個")
                                screenState = .item(.init(item: item, mode: .create))
                            }
                        }
                        Button {
                            guard screenState == nil else { return }
                            let editTextAlertState: EditTextAlertState = .init(
                                id: note.id.rawValue,
                                title: "新規リスト名",
                                text: "") { groupName in
                                    let group = SumGroup(name: groupName, items: [])
                                    withAnimation {
                                        store.update(group, in: noteID)
                                        scrollTargetGroup = group.id
                                    } completion: {
                                        Task { @MainActor in
                                            try await Task.sleep(for: .seconds(0.3))
                                            screenState = .group(group.id)
                                        }
                                    }
                                }
                            screenState = .text(editTextAlertState)
                        } label: {
                            Text("リスト")
                                .padding(.vertical, 15)
                                .padding(.horizontal, 25)
                        }
                    } label: {
                        SystemIcon(systemName: "plus", color: .blue, size: 60)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                    .padding()
                    .padding(.trailing, 10)
                }
            }
            .caluculatorInputSheet($screenState.calculatorInputState)
            // MARK: - Alert -
            .editTextAlert(screenState: $screenState)
            .discountPckerSheet($screenState.discountState)
            .navigationDestination(item: Binding<SumGroup.ID?>(from: $screenState)) { groupID in
                SumGroupView<Dependency>(noteID: noteID, groupID: groupID)
            }
            .showEditItemView($screenState.item) { state in
                switch state.mode {
                case .create:
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.3))
                        withAnimation {
                            store.update(state.item, in: noteID)
                            scrollTargetItem = state.item.id
                        }
                    }
                case .edit:
                    store.update(state.item, in: noteID)
                }
            }
            .alert(
                "リストを削除",
                isPresented: $screenState.removeGroupAlertState,
                presenting: screenState?.removeGroup
            ) { group in
                Button("キャンセル", role: .cancel) {
                    screenState = nil
                }
                Button("削除", role: .destructive) {
                    var note = note
                    note.groups.removeValue(forKey: group.id)
                    withAnimation {
                        _ = store.update(note)
                    }
                }
            } message: { group in
                Text("\(group.name)を削除しますか？")
            }
            .removeItemAlert($screenState) { item in
                var note = note
                note.items.removeValue(forKey: item.id)
                withAnimation {
                    _ = store.update(note)
                }
            }
            // MARK: - toolbar -
            .toolbar {
                Menu {
                    Button("ノート名を編集", systemImage: "square.and.pencil") {
                        guard screenState == nil else { return }
                        screenState = .text(
                            .init(id: note.id.rawValue, title: "ノート名", text: note.name) {
                                var note = note
                                note.name = $0
                                store.update(note)
                            }
                        )
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = note.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
            }
            // MARK: - navigationTitle -
            .navigationTitle(note.name)
        }
    }
}

// MARK: - ViewBuilders -
extension NoteView {
    @ViewBuilder
    func groups(_ note: SumNote) -> some View {
        ForEach(note.groups.values.elements) { group in
            Button {
                guard screenState == nil else { return }
                screenState = .group(group.id)
            } label: {
                HStack(spacing: 5) {
                    SystemIcon(systemName: "list.bullet.rectangle.portrait", color: .orange, size: 32)
                        .foregroundStyle(.white)
                        .padding(.trailing, 5)
                    Text(group.name)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    if let (totalQuantity, unitName) = group.totalQuantity() {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("(")
                            BFractionText(fraction: totalQuantity, textStyle: .footnote)
                            Text(unitName)
                                .font(.caption2)
                            Text(")")
                        }
                        .font(.footnote)
                        .layoutPriority(-1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("合計")
                            .font(.caption)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                        BFractionText(fraction: group.sum())
                        Text("円")
                            .font(.caption)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, -10)
                }
                .padding(.vertical, 3)
            }
            .listRowBackground(groupBackgroundColor(group.id))
            .foregroundStyle(Color(uiColor: .label))
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    guard screenState == nil else { return }
                    screenState = .removeGroup(group)
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
            .id(group.id)
        }
        .onMove { indexSet, index in
            var groups = note.groups.values.elements
            groups.move(fromOffsets: indexSet, toOffset: index)
            var note = note
            note.groups = groups.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
        .onDelete { indexSet in
            var groups = note.groups.values.elements
            groups.remove(atOffsets: indexSet)
            var note = note
            note.groups = groups.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
    }
    @ViewBuilder
    func items(_ note: SumNote) -> some View {
        ForEach(note.items.values) { item in
            SumItemCell(
                item: .init(get: {
                    item
                }, set: {
                    store.update($0, in: noteID)
                }),
                state: $screenState
            )
            .listRowBackground(screenState?.isShow(item) == true ? Color(uiColor: .systemFill) : .clear)
        }
        .onMove { indexSet, index in
            var items = note.items.values.elements
            items.move(fromOffsets: indexSet, toOffset: index)
            var note = note
            note.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
    }

    func groupBackgroundColor(_ id: SumGroup.ID) -> Color? {
        switch screenState {
        case .group(let groupID):
            if groupID == id {
                return Color(uiColor: .systemFill)
            }
        case .removeGroup(let group):
            if group.id == id {
                return Color.red.opacity(0.7)
            }
        default:
            break
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        let noteID = DummyDependency.noteStore.notes.first!.id
        NoteView<DummyDependency>(noteID)
    }
}

