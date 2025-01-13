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
                        groups(note)
                            .listRowBackground(Color.clear)
                        items(note)
                            .listRowBackground(Color.clear)
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
                // MARK: - 総計 -
                HStack {
                    Spacer()
                    HStack(alignment: .lastTextBaseline) {
                        Text("総計")
                            .foregroundStyle(.secondary)
                        BFractionText(fraction: note.sum(), textStyle: .title3)
                        Text("円")
                    }
                    .padding()
                    Spacer()
                }
                .ignoresSafeArea()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            // MARK: - Alert -
            .editTextAlert(editState: $editState)
            .sheet(item: Binding<EditFractionState?>(from: $editState)) { state in
                CalculatorInputView(
                    title: state.title,
                    value: state.fraction,
                    completion: state.completion
                ) {
                    editState = nil
                }
                .presentationDetents([.height(CalculatorLayoutLogics.displaySize(maxSize: UIScreen.main.bounds.size).height)]
                )
            }
            .overlay {
                if let state = editState?.discountState {
                    SumDiscountPicker(title: state.title, option: state.option, completion: state.completion) {
                        editState = nil
                    }
                }
            }
            .navigationDestination(item: Binding<SumGroup.ID?>(from: $editState)) { groupID in
                SumGroupView<Dependency>(noteID: noteID, groupID: groupID)
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
                    Button("新規アイテム作成", systemImage: "note.text.badge.plus") {
                        let item = SumItem(name: "新規アイテム", unitPrice: 0, quantity: 1, unitName: "個")
                        withAnimation {
                            store.update(item, in: noteID)
                            scrollTargetItem = item.id
                        }
                    }
                    Button("新規リスト作成", systemImage: "note.text.badge.plus") {
                        let group = SumGroup(name: "新規リスト", items: [])

                        withAnimation {
                            store.update(group, in: noteID)
                            scrollTargetGroup = group.id
                        }
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = note.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
                .disabled(editState?.discountState != nil)
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
            .foregroundStyle(Color(uiColor: .label))
            .buttonStyle(BorderlessButtonStyle())
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
            .buttonStyle(BorderlessButtonStyle())
            .id(item.id)
        }
        .onMove { indexSet, index in
            var items = note.items.values.elements
            items.move(fromOffsets: indexSet, toOffset: index)
            var note = note
            note.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
        .onDelete { indexSet in
            var items = note.items.values.elements
            items.remove(atOffsets: indexSet)
            var note = note
            note.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
            store.update(note)
        }
    }
}

#Preview {
    NavigationStack {
        let noteID = DummyDependency.noteStore.notes.first!.id
        NoteView<DummyDependency>(noteID)
    }
}

