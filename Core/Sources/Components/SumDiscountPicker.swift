import SwiftUI
import Entities

public struct SumDiscountPicker: View {
    let title: String
    let completion: (SumOption?) -> Void
    let cancel: () -> Void
    @State var selectedSumDiscount: SumOption.Style
    @State var numerator: Int
    var option: SumOption {
        .init(style: selectedSumDiscount, numerator)
    }
    public init(title: String, option: SumOption, completion: @escaping (SumOption?) -> Void, cancel: @escaping () -> Void) {
        self.title = title
        self.completion = completion
        self.cancel = cancel
        _selectedSumDiscount = .init(initialValue: option.style)
        _numerator = .init(initialValue: option.numerator)
    }
    public var body: some View {
        GeometryReader { gr in
            VStack {
                VStack {
                    VStack {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text(option.numerator.description)
                            Text(option.suffix)
                                .font(.caption)
                        }
                    }

                    Picker("Style", selection: $selectedSumDiscount) {
                        ForEach(SumOption.Style.allCases) { style in
                            Text(style.name)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Numerator", selection: $numerator) {
                        switch selectedSumDiscount {
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
                }
                .padding()
                .frame(maxWidth: gr.size.width  - 90)
                .background(
                    .ultraThinMaterial
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Button {
                    completion(option)
                } label: {
                    Text("確定").fontWeight(Font.Weight.bold)
                        .padding()
                        .frame(maxWidth: gr.size.width  - 90)
                        .background(
                            .ultraThinMaterial
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .overlay(alignment: .topTrailing) {
                Button("削除", role: .destructive) {
                    completion(nil)
                }
                .padding(5)
            }
            .position(x: gr.size.width / 2 ,y: gr.size.height - 200)
        }
        .onChange(of: selectedSumDiscount) {
            if case .decile = selectedSumDiscount {
                numerator = min(numerator, 9)
            }
        }
        .background {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    cancel()
                }
//                .background(.ultraThinMaterial)
//                .opacity(0.8)
        }
    }
}

#Preview {
    HStack {
        SumDiscountPicker(title: "sample", option: .dummy) { option in
            print(option?.description as Any)
        } cancel: {
            print("cancel")
        }
    }

}
