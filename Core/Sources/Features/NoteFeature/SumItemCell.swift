import SwiftUI
import Entities
import Components
import BigIntExtensions

struct SumItemCell: View {
    @Binding var item: SumItem
    @Binding var state: ScreenState?
    init(item: Binding<SumItem>, state: Binding<ScreenState?>) {
        self._item = item
        self._state = state
    }

    var body: some View {
        Button {
            state = .item(.init(item: item, mode: .edit))
        } label: {
            VStack {
                HStack {
                    Text(item.name)
                    + Text("  ")
                    + item.optionalDiscountText.foregroundStyle(.secondary)

                    Spacer()

                    Text("小計 ").font(.caption).foregroundStyle(.secondary)
                    + item.sum.text()
                    + Text(" 円").font(.caption).foregroundStyle(.secondary)
                }
                item.calculationDescription
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .padding(5)
            }
        }
        .tint(.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .buttonStyle(BorderlessButtonStyle())
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                setEditFraction(.unitPrice)
            } label: {
                Text("単価")
            }
            .tint(.indigo)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                setEditFraction(.quantity)
            } label: {
                Text("数量")
            }
            .tint(.green)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                guard state == nil else { return }
                state = .removeItem(item)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
        .id(item.id)
    }
}

extension SumItemCell {
    var hasDiscount: Bool {
        item.option.numerator != .zero
    }
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
    @Previewable @State var state: ScreenState? = nil
    SumItemCell(item: $item, state: $state)
}
