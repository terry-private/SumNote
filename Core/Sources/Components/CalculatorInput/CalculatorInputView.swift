import SwiftUI
import BigIntExtensions

public struct CalculatorInputView: View {
    let title: String
    let size: CGSize
    @State var state: CalculatorInputViewState
    public init(title: String = "", value: BFraction = .init(4, 1), size: CGSize, completion: @escaping (BFraction) -> Void, cancel: @escaping () -> Void) {
        self.title = title
        self.size = size
        state = CalculatorInputViewState(
            state: .fraction(value),
            completion: completion,
            cancel: cancel
        )
    }
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    state.cancel()
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

            HStack {
                VStack(spacing: 8) {
                    Button {
                        state.add1()
                    } label: {
                        Image(systemName: "chevron.up")
                            .padding()
                    }
                    Button {
                        state.subtract1()
                    } label: {
                        Image(systemName: "chevron.down")
                            .padding()
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
    GeometryReader { proxy in
        let size = CalculatorLayoutLogics.displaySize(maxSize: proxy.size)
        Color.clear
            .overlay {
                CalculatorInputView(title: "test test test test test test test test test test test", value: .init(1357, 100), size: size) {
                    print($0)
                } cancel: {
                    print("cancel tapped")
                }
                .frame(width: size.width, height: size.height)
            }
    }
}
