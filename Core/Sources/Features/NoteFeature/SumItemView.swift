import SwiftUI
import Entities
import Components
import BigIntExtensions

struct SumItemView: View {
    @Binding var item: SumItem
    @Binding var state: EditState?
    init(item: Binding<SumItem>, state: Binding<EditState?>) {
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
                    Button("割引", systemImage: "tag.slash.fill") {
                        setDiscountPciderState()
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

                if item.option.numerator != .zero {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("(\(item.option.numerator.description)\(Text(item.option.suffix).font(.caption)))")
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }

                Spacer()
            }
            HStack(alignment: .lastTextBaseline) {
                Button {
                    setEditFraction(.unitPrice)
                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        BFractionText(fraction: item.unitPrice)
                            .layoutPriority(1)
                        Text("円/\(item.unitName)")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(.secondary)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                }
                .tint(.primary)
                Button {
                    setEditFraction(.quantity)
                } label: {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        BFractionText(fraction: item.quantity)
                        Text(item.unitName)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                }
                .tint(.primary)
            }
            .padding(.horizontal, 5)
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Spacer()
                if item.option.numerator != .zero {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("小計")
                            .font(.caption)
                        BFractionText(fraction: item.subtotal)
                            .minimumScaleFactor(0.5)
                        Text("円")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .overlay {
                        Color.secondary.frame(height: 1)
                            .font(.caption)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .lastTextBaseline, spacing: 2) {
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
            .padding(.horizontal, 5)
        }
        .buttonStyle(BorderlessButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                guard state == nil else { return }
                state = .removeItem(item)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                guard state == nil else { return }
                state = .discount(
                    DiscountPickerState(title: "\(item.name) / 値引き", option: item.option) { option in
                        item.option = option
                        state = nil
                    }
                )
            } label: {
                Image(systemName: "tag.slash.fill")
            }
            .tint(.purple)
        }
        .id(item.id)
    }
}

extension SumItemView {
    func setAlert(title: String, _ keyPath: WritableKeyPath<SumItem, String>) {
        guard state == nil else { return }
        state = .text(.init(title: title, item: $item, keyPath))
    }
    func setDiscountPciderState() {
        guard state == nil else { return }
        state = .discount(
            DiscountPickerState(title: item.name, option: item.option) { option in
                item.option = option
                state = nil
            }
        )
    }
    func setEditFraction(_ property: FractionalProperty) {
        guard state == nil else { return }
        state = .fraction(
            CalculatorInputState(item: item, property: property) { result in
                item[keyPath: property.keyPath] = result
                state = nil
            }
        )
    }
}

#Preview {
    @Previewable @State var item: SumItem = .dummy(1)
    @Previewable @State var state: EditState? = nil
    SumItemView(item: $item, state: $state)
}
