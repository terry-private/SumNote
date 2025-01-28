import SwiftUI
import Entities
import CoreProtocols
import Components
import EditItemFeature

public struct SumGroupView<Dependency: DependencyProtocol>: View {
    @State var store = Dependency.noteStore
    @State var screenState: ScreenState?
    @State var scrollTarget: SumItem.ID?
    let noteID: SumNote.ID
    let groupID: SumGroup.ID
    public init(noteID: SumNote.ID, groupID: SumGroup.ID) {
        self.noteID = noteID
        self.groupID = groupID
    }
    public var body: some View {
        if let note = store.note(by: noteID), let group = note.groups[groupID] {
            VStack {
                ScrollViewReader { scrollProxy in
                    List {
                        Section {
                            ForEach(group.items.values.elements) { item in
                                SumItemCell(
                                    item: Binding<SumItem> {
                                        item
                                    } set: { newItem in
                                        print("⭐️", newItem, note.name, group.name)
                                        store.update(newItem, in: groupID, in: noteID)
                                    },
                                    state: $screenState
                                )
                                .listRowBackground(item.backgroundColor(screenState))
                            }
                            .onMove { indexSet, index in
                                var items = group.items.values.elements
                                items.move(fromOffsets: indexSet, toOffset: index)
                                var group = group
                                group.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
                                store.update(group, in: noteID)
                            }
                        } header: {
                            // MARK: - 総計 -
                            HStack {
                                Grid(alignment: .trailing) {
                                    if let (totalQuantity, unitName) = group.totalQuantity() {
                                        GridRow(alignment: .lastTextBaseline) {
                                            HStack {
                                                Spacer()
                                                Text("数量")
                                            }
                                            .layoutPriority(0)
                                            BFractionText(fraction: totalQuantity, textStyle: .headline)
                                                .foregroundStyle(Color(uiColor: .label))
                                                .layoutPriority(1)
                                            HStack {
                                                Text(unitName)
                                                Spacer()
                                            }
                                            .layoutPriority(0)
                                        }
                                    }
                                    GridRow(alignment: .lastTextBaseline) {
                                        HStack {
                                            Spacer()
                                            Text("合計")
                                        }
                                        .layoutPriority(0)
                                        BFractionText(fraction: group.sum(), textStyle: .headline)
                                            .foregroundStyle(Color(uiColor: .label))
                                            .layoutPriority(1)
                                        HStack {
                                            Text("円")
                                            Spacer()
                                        }
                                        .layoutPriority(0)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: scrollTarget) { _, newValue in
                        withAnimation {
                            scrollProxy.scrollTo(newValue)
                        }
                    }
                }
                HStack {
                    Menu {
                        Button("新規アイテム作成", systemImage: "note.text.badge.plus") {
                            let item = SumItem(name: "", unitPrice: 0, quantity: 1, unitName: "個")
                            screenState = .item(.init(item: item, mode: .create))
                        }
                        Button("テンプレートから作成", systemImage: "note.text.badge.plus") {
                        }
                    } label: {
                        Label("新規", systemImage: "plus.circle.fill")
                            .padding(.vertical, 15)
                            .padding(.horizontal, 25)
                    }
                    Spacer()
                }
            }
            // MARK: - Screen
            .editTextAlert(screenState: $screenState)
            .caluculatorInputSheet($screenState.calculatorInputState)
            .discountPckerSheet($screenState.discountState)
            .showEditItemView($screenState.item) { state in
                switch state.mode {
                case .create:
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.3))
                        withAnimation {
                            store.update(state.item, in: groupID, in: noteID)
                            scrollTarget = state.item.id
                        }
                    }
                case .edit:
                    store.update(state.item, in: groupID, in: noteID)
                }
            }
            .removeItemAlert($screenState) { item in
                var group = group
                group.items.removeValue(forKey: item.id)
                withAnimation {
                    _ = store.update(group, in: noteID)
                }
            }
            // MARK: - toolbar -
            .toolbar {
                Menu {
                    Button("リスト名を編集", systemImage: "square.and.pencil") {
                        setGroupNameEditTextAlert(group)
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = group.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
            }
            .navigationTitle(group.name)
        }
    }
    func setGroupNameEditTextAlert(_ group: SumGroup) {
        screenState = .text(
            EditTextAlertState(
                id: group.id.rawValue,
                title: "リスト名を編集",
                text: group.name
            ) {
                var group = group
                group.name = $0
                store.update(group, in: noteID)
            }
        )
    }
}
