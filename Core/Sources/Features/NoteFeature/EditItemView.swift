import Entities
import SwiftUI
import CoreProtocols
import Components

public struct EditItemView: View {
    public enum Mode {
        case create
        case edit
        var title: String {
            switch self {
            case .create: "新規作成"
            case .edit: "編集"
            }
        }
    }
    enum FocusPoint {
        case name
        case unitName
    }
    @State var screenState: ScreenState?
    @State var item: SumItem
    @FocusState var focusPoint: FocusPoint?
    let mode: Mode
    let completion: (SumItem) -> Void
    let dismiss: () -> Void
    var dismissButtonTitle: String {
        switch mode {
        case .create: "キャンセル"
        case .edit: "閉じる"
        }
    }
    let commonUnits = ["個", "袋", "箱", "本", "g", "kg", "ml", "L"]
    public init(item: SumItem, mode: Mode, completion: @escaping (SumItem) -> Void, dismiss: @escaping () -> Void) {
        self._item = .init(initialValue: item)
        self.mode = mode
        self.completion = completion
        self.dismiss = dismiss
    }
    public var body: some View {
        Form {
            Section {
                HStack {
                    Text("商品名")
                    TextField("", text: $item.name)
                        .textInputAutocapitalization(.never)
                        .focused($focusPoint, equals: .name)
                        .multilineTextAlignment(.trailing)
                }
                UnitOptionPcker($item.unitOption, unitOptions: [.g100])
                    .tint(.accentColor)
                HStack {
                    Text("単価")
                    Spacer()
                    Button {
                        focusPoint = nil
                        screenState = .fraction(.init(item: item, property: .unitPrice) { unitPrice in
                            item.unitPrice = unitPrice
                            screenState = nil
                        })
                    } label: {
                        item.unitPrice.text().add(suffix: item.unitPriceName)
                    }
                    .tint(.primary)
                }
                HStack {
                    Text("数量")
                    Spacer()
                    Button {
                        focusPoint = nil
                        screenState = .fraction(.init(item: item, property: .quantity) { quantity in
                            item.quantity = quantity
                            screenState = nil
                        })
                    } label: {
                        item.quantity.text()
                            .add(suffix: item.quantityUnitName)
                    }
                    .tint(.primary)
                }
                HStack(spacing: 10) {
                    Text("単位")
                    Spacer()
                    if let unitOption = item.unitOption {
                        Text(unitOption.baseUnitName)
                            .foregroundStyle(.secondary)
                    } else {
                        Menu {
                            ForEach(commonUnits, id: \.self) { unit in
                                Button {
                                    focusPoint = nil
                                    item.unitName = unit
                                } label: {
                                    Text(unit)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .padding(8)
                        }
                        TextField("単位", text: $item.unitName)
                            .textInputAutocapitalization(.never)
                            .multilineTextAlignment(.trailing)
                            .focused($focusPoint, equals: .unitName)
                    }
                }
                HStack {
                    Text("値引")
                    Spacer()
                    Button {
                        focusPoint = nil
                        screenState = .discount(.init(title: "値引", discount: item.discount) { discount in
                            item.discount = discount
                            screenState = nil
                        })
                    } label: {
                        if item.hasDiscount {
                            item.discountText
                        } else {
                            Text("なし")
                        }
                    }
                    .tint(.primary)
                }
            } header: {
                Text("入力")
            }
            Section {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 10) {
                        item.calculationDescription
                        + Text("\n")
                        + item.sum.text().bold()
                            .add(prefix: "小計", suffix: "円")
                    }
                    .foregroundStyle(.secondary)
                    .lineSpacing(5)
                    .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("計算")
            }

            // done button
            if mode == .create {
                Button {
                    completion(item)
                    dismiss()
                } label: {
                    Text("作成")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .caluculatorInputSheet($screenState.calculatorInputState)
        .discountPckerSheet($screenState.discountState)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(dismissButtonTitle) {
                focusPoint = nil
                dismiss()
            }
        }
        .onChange(of: item) {
            if mode == .edit {
                completion(item)
            }
        }
        .onAppear {
            if mode == .create {
                focusPoint = .name
            }
        }
    }
}

extension View {
    func showEditItemView(_ state: Binding<EditItemState?>, completion: @escaping (EditItemState) -> Void) -> some View {
        fullScreenCover(item: state) { targetState in
            NavigationStack {
                EditItemView(item: targetState.item, mode: targetState.mode) { editedItem in
                    completion(.init(item: editedItem, mode: targetState.mode))
                } dismiss: {
                    state.wrappedValue = nil
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var item: SumItem = .dummy(0)
    @Previewable @State var editItem: EditItemState?
    @Previewable @State var newItem: EditItemState?
    VStack {
        Button {
            newItem = .init(item: .init(name: "商品", unitPrice: .ZERO, quantity: .ONE, unitName: "個"), mode: .create)
        } label: {
            Text("新規作成")
        }
        Button {
            editItem = .init(item: item, mode: .edit)
        } label: {
            Text(item.name + " 編集")
        }
    }
    .showEditItemView($editItem) { state in
        item = state.item
    }
    .showEditItemView($newItem) { state in
        item = state.item
    }
}
