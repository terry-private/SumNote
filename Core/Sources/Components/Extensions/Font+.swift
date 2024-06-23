import SwiftUI

public extension Font.TextStyle {
    var uiFont: UIFont {
        switch self {
        case .body: UIFont.preferredFont(forTextStyle: .body)
        case .callout: UIFont.preferredFont(forTextStyle: .callout)
        case .largeTitle: UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title: UIFont.preferredFont(forTextStyle: .title1)
        case .title2: UIFont.preferredFont(forTextStyle: .title2)
        case .title3: UIFont.preferredFont(forTextStyle: .title3)
        case .headline: UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:UIFont.preferredFont(forTextStyle: .subheadline)
        case .footnote: UIFont.preferredFont(forTextStyle: .footnote)
        case .caption: UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2: UIFont.preferredFont(forTextStyle: .caption2)
        @unknown default: UIFont.preferredFont(forTextStyle: .body)
        }
    }
}

public extension Font {
    static func pointSize(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.pointSize
    }
    static func lineHeight(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.lineHeight
    }
    static func ascender(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.ascender
    }
    static func descender(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.descender
    }
    static func capHeight(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.capHeight
    }
    static func xHeight(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.xHeight
    }
    static func bottomSpacing(_ textStyle: TextStyle) -> CGFloat {
        textStyle.uiFont.bottomSpacing
    }
}

public extension UIFont {
    var bottomSpacing: CGFloat {
        lineHeight - ascender - descender
    }
}
