import SwiftUI
import Entities

public struct DiscountPicker: View {
    let title: String
    let completion: (SumOption) -> Void
    let cancel: () -> Void
    @State var selectedDiscount: SumOption.Style
    @State var numerator: Int
    var option: SumOption {
        .init(style: selectedDiscount, numerator)
    }
    public init(title: String, option: SumOption, completion: @escaping (SumOption) -> Void, cancel: @escaping () -> Void) {
        self.title = title
        self.completion = completion
        self.cancel = cancel
        _selectedDiscount = .init(initialValue: option.style)
        _numerator = .init(initialValue: option.numerator)
    }
    public init(_ state: DiscountPickerState, cancel: @escaping () -> Void) {
        self.title = state.title
        self.completion = state.completion
        self.cancel = cancel
        _selectedDiscount = .init(initialValue: state.option.style)
        _numerator = .init(initialValue: state.option.numerator)
    }
    public var body: some View {
        VStack(spacing: 10) {
            // top bar
            HStack {
                Text(title)
                Spacer()
                Button("キャンセル") {
                    cancel()
                }
            }
            .padding(10)
            .background(Color(uiColor: .tertiarySystemBackground))

            // contents
            VStack(spacing: 10)  {

                // description
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(option.numerator.description)
                    Text(option.suffix)
                        .font(.caption)
                }

                // style picker
                Picker("Style", selection: $selectedDiscount) {
                    ForEach(SumOption.Style.allCases) { style in
                        Text(style.name)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: 31)

                // numarator picker
                Picker("Numerator", selection: $numerator) {
                    switch selectedDiscount {
                    case .decile:
                        ForEach(0..<10) { numerator in
                            Text(numerator.description)
                        }
                    case .percentile:
                        ForEach(0..<100) { numerator in
                            Text(numerator.description)
                        }
                        .pickerStyle(.wheel)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 215)

                // done button
                Button {
                    completion(option)
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
        .background(Color(uiColor: .systemGroupedBackground
                         ))
        .onChange(of: selectedDiscount) {
            if case .decile = selectedDiscount {
                numerator = min(numerator, 9)
            }
        }
    }
}

#Preview {
    HStack {
        DiscountPicker(title: "sample", option: .dummy) { option in
            print(option.description)
        } cancel: {
            print("cancel")
        }
    }
    .background(Color.secondary)

}
