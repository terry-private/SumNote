import SwiftUI
import Entities

public struct DiscountPicker: View {
    let title: String
    let completion: (SumDiscount) -> Void
    let cancel: () -> Void
    @State var selectedStyle: SumDiscount.Style
    @State var numerator: Int
    var discount: SumDiscount {
        .init(style: selectedStyle, numerator)
    }
    public init(title: String, discount: SumDiscount, completion: @escaping (SumDiscount) -> Void, cancel: @escaping () -> Void) {
        self.title = title
        self.completion = completion
        self.cancel = cancel
        _selectedStyle = .init(initialValue: discount.style)
        _numerator = .init(initialValue: discount.numerator)
    }
    public init(_ state: DiscountPickerState, cancel: @escaping () -> Void) {
        self.title = state.title
        self.completion = state.completion
        self.cancel = cancel
        _selectedStyle = .init(initialValue: state.discount.style)
        _numerator = .init(initialValue: state.discount.numerator)
    }
    public var body: some View {
        VStack(spacing: 10) {
            // top bar
            HStack(spacing: 0) {
                Button {
                    cancel()
                } label: {
                    Text("キャンセル")
                        .lineLimit(1)
                }
                .layoutPriority(3)
                Spacer()
//                .frame(maxWidth: .infinity, alignment: .leading)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(2)
                Spacer()
                Text("キャンセル")
                    .lineLimit(1)
                    .opacity(0)
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))

            // contents
            VStack(spacing: 10)  {

                // description
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(discount.numerator.description)
                    Text(discount.suffix)
                        .font(.caption)
                }

                // style picker
                Picker("Style", selection: $selectedStyle) {
                    ForEach(SumDiscount.Style.allCases) { style in
                        Text(style.name)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: 31)

                // numarator picker
                Picker("Numerator", selection: $numerator) {
                    ForEach(selectedStyle.selectableRange, id: \.self) { numerator in
                        Text(numerator.description)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 215)

                // done button
                Button {
                    completion(discount)
                } label: {
                    Text("確定")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(
                            Color(uiColor: .secondarySystemGroupedBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 10)
        }
        .onChange(of: selectedStyle) { oldValue, newValue in
            numerator = numerator * newValue.denominator / oldValue.denominator
        }
    }
}

#Preview {
    HStack {
        DiscountPicker(title: "sample", discount: .dummy) { discount in
            print(discount.description)
        } cancel: {
            print("cancel")
        }
    }
    .background(Color.secondary)

}
