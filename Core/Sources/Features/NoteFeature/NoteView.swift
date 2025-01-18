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
    @State var editState: EditState?
    @State var scrollTargetItem: SumItem.ID?
    @State var scrollTargetGroup: SumGroup.ID?
    public init(_ noteID: SumNote.ID) {
        self.noteID = noteID
    }
    public var body: some View {
        if let note = store.note(by: noteID) {
            VStack(spacing: 0) {
                ScrollViewReader { scrollProxy in
                    List {
                        Section {
                            groups(note)
                            items(note)
                                .listRowBackground(Color.clear)
                        } header: {
                            // MARK: - 総計 -
                            HStack {
                                Spacer()
                                HStack(alignment: .lastTextBaseline) {
                                    Text("総計")
                                    BFractionText(fraction: note.sum(), textStyle: .headline)
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
                }
                HStack {
                    Menu {
                        Button("新規アイテム作成", systemImage: "note.text.badge.plus") {
                            let item = SumItem(name: "新規アイテム", unitPrice: 0, quantity: 1, unitName: "個")
                            withAnimation {
                                store.update(item, in: noteID)
                                scrollTargetItem = item.id
                            }
                        }
                        Button("テンプレートから作成", systemImage: "note.text.badge.plus") {
                        }
                    } label: {
                        Label("新規", systemImage: "plus.circle.fill")
                            .padding(.vertical, 15)
                            .padding(.horizontal, 25)
                    }
                    Spacer()
                    Button {
                        let group = SumGroup(name: "新規リスト", items: [])

                        withAnimation {
                            store.update(group, in: noteID)
                            scrollTargetGroup = group.id
                        }
                    } label: {
                        Text("リストを追加")
                            .padding(.vertical, 15)
                            .padding(.horizontal, 25)
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .caluculatorInputSheet($editState.calculatorInputState)
            // MARK: - Alert -
            .editTextAlert(editState: $editState)
            .discountPckerSheet($editState.discountState)
            .navigationDestination(item: Binding<SumGroup.ID?>(from: $editState)) { groupID in
                SumGroupView<Dependency>(noteID: noteID, groupID: groupID)
            }
            .alert(
                "リストを削除",
                isPresented: $editState.removeGroupAlertState,
                presenting: editState?.removeGroup
            ) { group in
                Button("キャンセル", role: .cancel) {
                    editState = nil
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
            .alert(
                "アイテムを削除",
                isPresented: $editState.removeItemAlertState,
                presenting: editState?.removeItem
            ) { item in
                Button("キャンセル", role: .cancel) {
                    editState = nil
                }
                Button("削除", role: .destructive) {
                    var note = note
                    note.items.removeValue(forKey: item.id)
                    withAnimation {
                        _ = store.update(note)
                    }
                }
            } message: { item in
                Text("\(item.name)を削除しますか？")
            }
            // MARK: - toolbar -
            .toolbar {
                Menu {
                    Button("ノート名を編集", systemImage: "square.and.pencil") {
                        guard editState == nil else { return }
                        editState = .text(
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
                guard editState == nil else { return }
                editState = .group(group.id)
            } label: {
                HStack(spacing: 5) {
                    SystemIcon(systemName: "note.text", color: .orange, size: 22)
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
            }
            .listRowBackground(groupBackgroundColor(group.id))
            .foregroundStyle(Color(uiColor: .label))
            .buttonStyle(BorderlessButtonStyle())
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    guard editState == nil else { return }
                    editState = .removeGroup(group)
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
            SumItemView(
                item: .init(get: {
                    item
                }, set: {
                    store.update($0, in: noteID)
                }),
                state: $editState
            )
            .listRowBackground(itemBackgroundColor(item))
        }
        .onMove { indexSet, index in
            var items = note.items.values.elements
            items.move(fromOffsets: indexSet, toOffset: index)
            var note = note
            note.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
    }

    func groupBackgroundColor(_ id: SumGroup.ID) -> Color {
        if editState?.removeGroup?.id == id {
            Color.red.opacity(0.2)
        } else {
            Color.clear
        }
    }
    func itemBackgroundColor(_ target: SumItem) -> Color {
        switch editState {
        case .discount(let state):
            if state.id == target.option.id {
                return Color.purple.opacity(0.7)
            }
        case .removeItem(let item):
            if item.id == target.id {
                return Color.red.opacity(0.7)
            }
        case .fraction(let state):
            if state.id == target.id {
                switch state.property {
                case .unitPrice:
                    return Color.indigo.opacity(0.7)
                case .quantity:
                    return Color.green.opacity(0.7)
                }
            }
        default:
            break
        }
        return Color.clear
    }
}

#Preview {
    NavigationStack {
        let noteID = DummyDependency.noteStore.notes.first!.id
        NoteView<DummyDependency>(noteID)
    }
}

