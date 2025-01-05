import SwiftUI
import Entities
import Components

public struct SumGroupView: View {
    @Binding var parent: SumGroup2
    @State var sumGroup: SumGroup2
    @State var editState: EditState?
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
                        BFractionText(fraction: sumGroup.sum(), textStyle: .title3)
                            .layoutPriority(1)
                        HStack {
                            Text("円")
                            Spacer()
                        }
                        .layoutPriority(0)
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
                            id: sumGroup.id.rawValue,
                            title: "グループ名を編集",
                            text: sumGroup.name
                        ) {
                            sumGroup.name = $0
                            parent.name = $0
                        }
                    )
                }
                Button("テキストコピー", systemImage: "pencil") {
                    UIPasteboard.general.string = sumGroup.description()
                }
            } label: {
                Label("menu", systemImage: "line.3.horizontal.circle")
            }
            .disabled(editState?.discountState != nil)
        }
        .navigationTitle(sumGroup.name)
    }
}
