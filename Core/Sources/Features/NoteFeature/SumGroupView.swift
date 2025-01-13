import SwiftUI
import Entities
import CoreProtocols
import Components

public struct SumGroupView<Dependency: DependencyProtocol>: View {
    @State var store = Dependency.noteStore
    @State var editState: EditState?
    @State var scrollTarget: SumItem.ID?
    let noteID: SumNote.ID
    let groupID: SumGroup.ID
    public init(noteID: SumNote.ID, groupID: SumGroup.ID) {
        self.noteID = noteID
        self.groupID = groupID
    }
    public var body: some View {
        if let group = store.note(by: noteID)?.groups[groupID] {
            VStack {
                ScrollViewReader { scrollProxy in
                    List {
                        ForEach(group.items.values.elements) { item in
                            SumItemView(
                                item: Binding<SumItem> {
                                    item
                                } set: { newItem in
                                    store.update(newItem, in: groupID, in: noteID)
                                },
                                state: $editState
                            )
                            .buttonStyle(BorderlessButtonStyle())
                            .id(item.id)
                        }
                        .onMove { indexSet, index in
                            var items = group.items.values.elements
                            items.move(fromOffsets: indexSet, toOffset: index)
                            var group = group
                            group.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
                            store.update(group, in: noteID)
                        }
                        .onDelete { indexSet in
                            var group = group
                            var items = group.items.values.elements
                            items.remove(atOffsets: indexSet)
                            group.items = items.reduce(into: [:]) { $0[$1.id] = $1 }
                            store.update(group, in: noteID)
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: scrollTarget) { _, newValue in
                        print("onChange", newValue as Any)
                        guard let newValue else { return }
                        withAnimation {
                            scrollProxy.scrollTo(newValue)
                        } completion: {
//                            scrollTarget = nil
                        }
                    }
                }
                // MARK: - 総計 -
                HStack {
                    Grid(alignment: .trailing) {
                        if let (totalQuantity, unitName) = group.totalQuantity() {
                            GridRow(alignment: .lastTextBaseline) {
                                HStack {
                                    Spacer()
                                    Text("数量")
                                        .foregroundStyle(.secondary)
                                }
                                .layoutPriority(0)
                                BFractionText(fraction: totalQuantity, textStyle: .title3)
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
                                    .foregroundStyle(.secondary)
                            }
                            .layoutPriority(0)
                            BFractionText(fraction: group.sum(), textStyle: .title3)
                                .layoutPriority(1)
                            HStack {
                                Text("円")
                                Spacer()
                            }
                            .layoutPriority(0)
                        }
                    }
                    .padding()
                }
                .ignoresSafeArea()
            }
            .editTextAlert(editState: $editState)
            .sheet(item: Binding<EditFractionState?>(from: $editState)) { state in
                CalculatorInputView(
                    title: state.title,
                    value: state.fraction,
                    completion: state.completion
                ) {
                    editState = nil
                }
                .presentationDetents(
                    [.height(CalculatorLayoutLogics.displaySize(maxSize: UIScreen.main.bounds.size).height)]
                )
            }
            .overlay {
                if let state = editState?.discountState {
                    SumDiscountPicker(title: state.title, option: state.option, completion: state.completion) {
                        editState = nil
                    }
                }
            }
            // MARK: - toolbar -
            .toolbar {
                Menu {
                    Button("グループ名を編集", systemImage: "square.and.pencil") {
                        editState = .text(
                            EditTextAlertState(
                                id: group.id.rawValue,
                                title: "グループ名を編集",
                                text: group.name
                            ) {
                                var group = group
                                group.name = $0
                                store.update(group, in: noteID)
                            }
                        )
                    }
                    Button("新規追加", systemImage: "plus") {
                        let item = SumItem(name: "アイテム", unitPrice: 0, quantity: 1, unitName: "個")
                        _ = withAnimation {
                            store.update(item, in: groupID, in: noteID)
                        } completion: {
                            scrollTarget = item.id
                        }
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = group.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
                .disabled(editState?.discountState != nil)
            }
            .navigationTitle(group.name)
        }
    }
}
