import SwiftUI
import BigInt

public struct CalculatorInputView: View {
    let size: CGSize
    @State var operating: Operating?
    @State var result: BFraction?
    @State var editingValue: String
    @State var state: CalculatorInputViewState
    var disPlayValue: String {
        if let result {
            result.asDecimalString(precision: 20)
        } else {
            editingValue
        }
    }
    public init(value: BFraction = .init(4, 1), maxSize: CGSize = UIScreen.main.bounds.size) {
        size = CalculatorLayoutLogics.displaySize(maxSize: maxSize)
        editingValue = value.asDouble().description
        state = CalculatorInputViewState(state: .fraction(value))
    }
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("キャンセル") {
                    print("Cancel")
                }
                Spacer()
                Button("確定") {
                    print("Done")
                }
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))

            HStack {
                Spacer()
                if let operating = state.operating {
                    BFractionText(fraction: operating.fraction, textStyle: .title2, rounded: 20, currencyMode: false)
                    Text(operating.operation.description)
                }
            }
            .foregroundColor(.orange)
            .frame(height: Font.TextStyle.title2.uiFont.lineHeight)
            .padding(.horizontal, 10)

            HStack {
                Spacer()
                Text(state.state.display)
                    .font(.largeTitle)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)

            buttonPad
        }
        .frame(width: size.width, height: size.height)
    }
}

extension CalculatorInputView {
    @ViewBuilder
    private var buttonPad: some View {
        ButtonPad(buttonTypes: state.buttonTypes) { buttonType, padSize in
            Button(buttonType.description) {
                state.onTap(buttonType)
            }
            .buttonStyle(CalculatorButtonStyle(
                size: getButtonSize(screenWidth: padSize.width),
                backgroundColor: buttonType.backgroundColor,
                foregroundColor: buttonType.foregroundColor,
                isWide: buttonType == .digit(.zero))
            )
        }
    }

    private func getButtonSize(screenWidth: CGFloat) -> CGFloat {
        let buttonCount: CGFloat = 4
        let spacingCount = buttonCount + 1
        let buttonSize = (screenWidth - (spacingCount * CalculatorLayoutLogics.padding)) / buttonCount
        print(screenWidth, buttonSize)
        return buttonSize
    }
}

#Preview {
    CalculatorInputView(value: .init(1357, 100))}
