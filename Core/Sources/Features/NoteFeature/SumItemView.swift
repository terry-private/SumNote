import SwiftUI
import Entities
import Components
import BigIntExtensions

struct SumItemView: View {
    @Binding var item: SumItem2
    @Binding var state: EditState?
    init(item: Binding<SumItem2>, state: Binding<EditState?>) {
        self._item = item
        self._state = state
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
                            item.option = .init(style: .percentile, 10)
                        }
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .padding(.vertical, 8)
                        .padding(.trailing, 5)
                }
                .padding(.vertical, -8)
                Text(item.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Spacer()
                    Text("小計")
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    BFractionText(fraction: item.sum)
                        .minimumScaleFactor(0.5)
                    Text("円")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            VStack(spacing: 0) {
                HStack(alignment: .lastTextBaseline) {
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
                    SumItemValueButton(iconSystemName: "cart.fill.badge.plus", iconColor: .green, title: "数量") {
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
                                    item.option = option
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
        state = .text(.init(title: title, item: $item, keyPath))
    }
    func setEditFraction(title: String, _ keyPath: WritableKeyPath<SumItem2, BFraction>) {
        guard state == nil else { return }
        state = .fraction(
            EditFractionState(
                id: item.id.rawValue,
                title: title,
                fraction: item[keyPath: keyPath],
                completion: {
                    item[keyPath: keyPath] = $0
                    state = nil
                }
            )
        )
    }
}

#Preview {
    @Previewable @State var item: SumItem2 = .dummy(1)
    @Previewable @State var state: EditState? = nil
    VStack {
        Spacer()
        SumItemView(item: $item, state: $state)
//        Grid {
//            GridRow {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.red)
//                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.blue)
//                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.green)
//                    .aspectRatio(1, contentMode: .fit)  // これで正方形を維持
//            }
//        }
    }
}
