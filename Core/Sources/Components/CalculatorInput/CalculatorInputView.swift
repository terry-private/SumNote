import SwiftUI
import BigIntExtensions

public struct CalculatorInputView: View {
    let size: CGSize
    let title: String
    @State var state: CalculatorInputViewState
    public init(title: String = "", value: BFraction = .init(4, 1), maxSize: CGSize = UIScreen.main.bounds.size, completion: @escaping (BFraction) -> Void, cancel: @escaping () -> Void) {
        self.title = title
        size = CalculatorLayoutLogics.displaySize(maxSize: maxSize)
        state = CalculatorInputViewState(
            state: .fraction(value),
            completion: completion,
            cancel: cancel
        )
    }
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                Spacer()
                Button("キャンセル") {
                    state.cancel()
                }
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemBackground))

            HStack {
                VStack(spacing: 8) {
                    Button {
                        state.add1()
                    } label: {
                        Capsule()
                            .overlay {
                                Text("+1")
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 44)
                    }
                    Button {
                        state.subtract1()
                    } label: {
                        Capsule()
                            .overlay {
                                Text("-1")
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 44)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, -5)
                .frame(height: Font.TextStyle.title2.uiFont.lineHeight + Font.TextStyle.largeTitle.uiFont.lineHeight + 10)
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        if let operating = state.operating {
                            BFractionText(
                                fraction: operating.fraction,
                                textStyle: .title2,
                                rounded: 20,
                                currencyMode: false
                            )
                            Text(operating.operation.description)
                        }
                    }
                    .foregroundColor(.orange)
                    .frame(height: Font.TextStyle.title2.uiFont.lineHeight)

                    HStack {
                        Text(state.state.display)
                            .font(.largeTitle)
                            .monospacedDigit()
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 5)
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
        return max(.zero, buttonSize) // Maintain non-negative values
    }
}

#Preview {
    CalculatorInputView(value: .init(1357, 100)) {
        print($0)
    } cancel: {
        print("cancel tapped")
    }
}
