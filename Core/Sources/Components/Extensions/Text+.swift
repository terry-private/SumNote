import SwiftUI

public extension Text {
    func add(prefix: String = "", suffix: String = "", font: Font = .caption, color: Color = .secondary) -> Text {
        Text(prefix).font(font).foregroundStyle(color) + Text(" ") + self + Text(" ") + Text(suffix).font(font).foregroundStyle(color)
    }
}
