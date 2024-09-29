import SwiftUI

public enum CalculatorLayoutLogics {
    internal static let padding: CGFloat = 12.0

    public static func displaySize(maxSize: CGSize) -> CGSize {
        let upperHeight = Font.TextStyle.body.uiFont.lineHeight + 20 + Font.TextStyle.title2.uiFont.lineHeight + Font.TextStyle.largeTitle.uiFont.lineHeight
        let buttonPadMaxHeight = maxSize.height - upperHeight
        let buttonPadMaxSize: CGSize = .init(width: maxSize.width, height: buttonPadMaxHeight)
        let buttonPadSize = padSize(viewSize: buttonPadMaxSize)
        return CGSize(width: buttonPadSize.width, height: buttonPadSize.height + upperHeight)
    }
    internal static func padSize(viewSize: CGSize, spacing: CGFloat = 12, fromSheetHeight: Bool = false) -> CGSize {
        let buttonHCount: CGFloat = 4
        let spacingHCount: CGFloat = 5

        let buttonVCount: CGFloat = 5
        let spacingVCount: CGFloat = 6

        let forWidth: CGSize = {
            let buttonSize = (viewSize.width - (spacingHCount * spacing)) / buttonHCount
            let height = buttonSize * buttonVCount + spacing * spacingVCount
            return .init(width: viewSize.width, height: height)
        }()
        guard viewSize.height < forWidth.height else {
            return forWidth
        }
        let buttonSize = (viewSize.height - spacingVCount * spacing) / buttonVCount
        let padSize = CGSize(width: buttonSize * buttonHCount + spacing * spacingHCount, height: viewSize.height)
        return padSize
    }
}
