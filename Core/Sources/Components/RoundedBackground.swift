import SwiftUI

// 使ってないので消して良いかも
public struct RoundedBackground: ViewModifier {
    let contentMaxHeight: CGFloat
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    public init(
        contentMaxHeight: CGFloat = Font.lineHeight(.body),
        padding: CGFloat = 6,
        cornerRadius: CGFloat = 6,
        backgroundColor: Color = .init(UIColor.secondarySystemBackground)
    ) {
        self.contentMaxHeight = contentMaxHeight
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
    }
    public func body(content: Content) -> some View {
        content
            .frame(maxHeight: contentMaxHeight)
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(backgroundColor)
            }
    }
}

public extension View {
    func roundedBackground(
        contentMaxHeight: CGFloat = Font.lineHeight(.body),
        padding: CGFloat = 6,
        cornerRadius: CGFloat = 6,
        backgroundColor: Color = .init(UIColor.secondarySystemBackground)
    ) -> some View {
        modifier(
            RoundedBackground(
                contentMaxHeight: contentMaxHeight,
                padding: padding,
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor
            )
        )
    }
}

#Preview {
    Text("test")
        .roundedBackground()
}
