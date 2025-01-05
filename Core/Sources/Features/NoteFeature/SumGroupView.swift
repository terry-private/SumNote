import SwiftUI
import Entities
import Components

public struct SumGroupView: View {
    @Environment(\.editMode) private var editMode
    @Binding var parent: SumGroup2
    @State var sumGroup: SumGroup2
    @State var editState: EditStete?
    public init(sumGroup: Binding<SumGroup2>) {
        self._parent = sumGroup
        self._sumGroup = .init(initialValue: sumGroup.wrappedValue)
    }
    public var body: some View {
        VStack {
            List($sumGroup.items) { $item in
                SumItemView(
                    item: $item,
                    state: $editState
                )
                .buttonStyle(BorderlessButtonStyle())
            }
            .listStyle(.plain)
            // MARK: - 総計 -
            HStack {
                Grid(alignment: .trailing) {
                    if let (totalQuantity, unitName) = sumGroup.totalQuantity() {
                        GridRow(alignment: .lastTextBaseline) {
                            HStack {
                                Spacer()
                                Text("数量")
                                    .foregroundStyle(.secondary)
                            }
                            BFractionText(fraction: totalQuantity, textStyle: .title3)
                            HStack {
                                Text(unitName)
                                Spacer()
                            }
                        }
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        HStack {
                            Spacer()
                            Text("合計")
                                .foregroundStyle(.secondary)
                        }
                        BFractionText(fraction: sumGroup.sum(), textStyle: .title3)
                        HStack {
                            Text("円")
                            Spacer()
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .ignoresSafeArea()
        }
        .onChange(of: sumGroup) {
            parent = sumGroup
        }
        .alert(
            editState?.textState?.title ?? "",
            isPresented: .bool(from: $editState),
            presenting: editState?.textState
        ) { textState in
            TextField("テキストフィールド", text: textState.text)
            Button("Cancel", action: {})
            Button("OK") {
                guard !textState.text.wrappedValue.isBlank() else { return }
                textState.completion(textState.text.wrappedValue)
            }
        }
        .sheet(item: .editFractionState(from: $editState)) { state in
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
        // MARK: - toolbar -
        .toolbar {
            if editMode?.wrappedValue.isEditing == true {
                Button("完了") {
                    withAnimation {
                        editMode?.wrappedValue = .inactive
                    }
                }
            } else {
                Menu {
                    Button("ノート名を編集", systemImage: "square.and.pencil") {
//                        setAlert(title: "表題を編集", binding: $note.name)
                    }
                    Button("グループ編集モード") {
                        withAnimation {
                            editMode?.wrappedValue = .active
                        }
                    }
                    Button("空のグループを追加", systemImage: "note.text.badge.plus") {
                        withAnimation {
//                            let newTable = SumGroup(name: "グループ\(note.groups.count+1)", items: [.init(name: "アイテム", unitPrice: 0, quantity: 0, unitName: "個")])
//                            note.groups.append(newTable)
//                            addedTableID = newTable.id
                        }
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = sumGroup.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
                .disabled(editState?.discountState != nil)
            }
        }
        .navigationTitle(sumGroup.name)
    }
}
