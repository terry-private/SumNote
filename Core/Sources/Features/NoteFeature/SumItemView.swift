import SwiftUI
import Entities
import Components
import BigIntExtensions

struct SumItemView: View {
    var item: SumItem2
    @Binding var state: EditStete?
    var update: (SumItem2) -> ()
    init(item: SumItem2, state: Binding<EditStete?>, update: @escaping (SumItem2) -> Void) {
        self.item = item
        self._state = state
        self.update = update
    }

    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("品名を編集", systemImage: "square.and.pencil") {
                        setAlert(title: "品名を編集", \.name)
                    }
                    Button("単位を編集", systemImage: "square.and.pencil") {
                        setAlert(title: "単位を編集", \.unitName)
                    }
                    if item.option == nil {
                        Button("割引を追加", systemImage: "tag.slash.fill") {
                            var item = self.item
                            item.option = .init(style: .percentile, 10)
                            update(item)
                        }
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .padding(.vertical, 8)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, -8)
                Text(item.name)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Spacer()
                    Text("小計")
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    BFractionText(fraction: item.sum)
                    Text("円")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Grid(verticalSpacing: 0) {
                GridRow(alignment: .lastTextBaseline) {
                    SumItemValueButton(iconSystemName: "yensign", iconColor: .indigo, title: "単価") {
                        setEditFraction(title: "\(item.name) / 単価", \.unitPrice)
                    } content: {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {

                            BFractionText(fraction: item.unitPrice)
                                .layoutPriority(1)
                            Text("円/\(item.unitName)")
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.indigo)
                    SumItemValueButton(iconSystemName: "cart.fill", iconColor: .green, title: "数量") {
                        setEditFraction(title: "\(item.name) / 数量", \.quantity)
                    } content:  {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            BFractionText(fraction: item.quantity)
                            Text(item.unitName)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(.blue)
                    if let option = item.option {
                        SumItemValueButton(iconSystemName: "tag.slash.fill", iconColor: .red, title: "値引き") {
                            guard state == nil else { return }
                            state = .discount(
                                EditDiscountState(title: item.name, option: option) { option in
                                    var item = self.item
                                    item.option = option
                                    update(item)
                                    state = nil
                                }
                            )
                        } content: {
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text(option.numerator.description)
                                Text(option.suffix)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .foregroundStyle(.red)
                    } else {
                        SumItemValueButton(iconSystemName: "tag.slash.fill", iconColor: .red, title: "値引き", disabled: true) {
                        } content: {
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text("なし")
                            }
                        }
                        .foregroundStyle(.red)
                    }
                    Spacer()
                }
            }
            .padding(5)
        }
        // MARK: - Alert -
//        .alert(state?.editNameAlert?.title ?? "", isPresented: .bool(for: state), presenting) {
//            if let editNameAlert {
//                TextField("テキストフィールド", text: $editNameAlertText)
//                Button("Cancel", action: {})
//                Button("OK") {
//                    guard !editNameAlertText.isBlank() else { return }
//                    editNameAlert.binding.wrappedValue = editNameAlertText
//                }
//            }
//        }
    }
}

extension SumItemView {
    func setAlert(title: String, _ keyPath: WritableKeyPath<SumItem2, String>) {
        guard state == nil else { return }
        var tmpText: String = item[keyPath: keyPath]
        let bindingText: Binding<String> = .init(get: { tmpText }, set: { tmpText = $0 })
        state = .text(
            EditTextAlertState(
                id: item.id.rawValue,
                title: title,
                text: bindingText,
                completion: {
                    var item = self.item
                    item[keyPath: keyPath] = $0
                    update(item)
                    state = nil
                }
            )
        )
    }
    func setEditFraction(title: String, _ keyPath: WritableKeyPath<SumItem2, BFraction>) {
        guard state == nil else { return }
        state = .fraction(
            EditFractionState(
                id: item.id.rawValue,
                title: title,
                fraction: item[keyPath: keyPath],
                completion: {
                    var item = self.item
                    item[keyPath: keyPath] = $0
                    update(item)
                    state = nil
                }
            )
        )
    }
}

#Preview {
    @Previewable @State var state: EditStete? = nil
    VStack {
        SumItemView(item: .dummy(1), state: $state) { item in
            print(item)
        }
        Grid {
            GridRow {
                HStack {
                    Spacer()
                    Spacer()
                }
                HStack {
                    Spacer()
                    Spacer()
                }
                HStack {
                    Spacer()
                }
            }
            .frame(height: 0)
            GridRow {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//                    .frame(width: geometry.size.width / 3)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//                    .frame(width: geometry.size.width / 3)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//                    .frame(width: geometry.size.width / 3)
            }
        }
    }
}
