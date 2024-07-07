import SwiftUI
struct ButtonPad<Content: View>: View {
    private let maxWidth: CGFloat
    private let maxHeight: CGFloat
    private let spacing: CGFloat
    private let content: (ButtonType, CGSize) -> Content

    @State var size: CGSize = .zero
    var buttonTypes: [[ButtonType]]

    init(maxWidth: CGFloat = .infinity, maxHeight: CGFloat = .infinity, spacing: CGFloat = 12, buttonTypes: [[ButtonType]], content: @escaping (ButtonType, CGSize) -> Content) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.spacing = spacing
        self.buttonTypes = buttonTypes
        self.content = content
    }

    public var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChangeFrame {
                size = CalculatorLayoutLogics.padSize(viewSize: $0, spacing: spacing)
                print("onChange", $0)
            }
            .overlay {
                VStack(spacing: CalculatorLayoutLogics.padding) {
                    let _ = print("currentSize", size)
                    ForEach(buttonTypes, id: \.self) { row in
                        HStack(spacing: CalculatorLayoutLogics.padding) {
                            ForEach(row, id: \.self) { buttonType in
                                content(buttonType, size)
                            }
                        }
                    }
                }
            }
    }

}



#Preview {
    var calculationButtonTypes: [[ButtonType]] {
        [
            [.allClear, .backSpace, .percent, .operation(.division)],
            [.digit(.seven), .digit(.eight), .digit(.nine), .operation(.multiplication)],
            [.digit(.four), .digit(.five), .digit(.six), .operation(.subtraction)],
            [.digit(.one), .digit(.two), .digit(.three), .operation(.addition)],
            [.digit(.zero), .decimal, .equals]
        ]
    }
    ButtonPad(
        buttonTypes: calculationButtonTypes
    ) { type, size in
        let buttonSize = (size.width - CalculatorLayoutLogics.padding * 5)/4
        return Color.red
            .frame(width: buttonSize, height: buttonSize)
            .overlay {
                VStack {
                    Text(type.description)
                    Text("\(buttonSize)")
                }
            }
    }
}
