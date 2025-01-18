import SwiftUI

public enum DiscountLayoutLogics {
    internal static var bodyHeight: CGFloat { Font.TextStyle.body.uiFont.lineHeight }
    internal static let verticalSpacing: CGFloat = 10

    public static func displaySize(maxSize: CGSize) -> CGSize {
        let topBarHeight: CGFloat = bodyHeight + 20 // padding
        let descriptionHeight: CGFloat = bodyHeight
        let stylePickerHeight: CGFloat = 31
        let numeratorPickerHeight: CGFloat = 215
        let doneButtonHeight: CGFloat = bodyHeight + 20 // padding
        let bottomSpace: CGFloat = 10
        let totalHeight: CGFloat = topBarHeight + descriptionHeight + stylePickerHeight + numeratorPickerHeight + doneButtonHeight + bottomSpace + verticalSpacing * 5
        return CGSize(width: min(500, maxSize.width), height: totalHeight)
    }
}
