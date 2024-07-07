import SwiftUI

struct CalculatorButtonStyle: ButtonStyle {

    var size: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    var isWide: Bool = false

    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 32, weight: .medium))
                .frame(width: size, height: size)
                .frame(maxWidth: isWide ? CalculatorLayoutLogics.padding + size * 2 : size, alignment: .leading)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .overlay {
                    if configuration.isPressed {
                        Color(white: 1.0, opacity: 0.2)
                    }
                }
                .clipShape(Capsule())
    }
}
