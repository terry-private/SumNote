import SwiftUI

public extension Text {
    func add(prefix: String = "", suffix: String = "", font: Font = .caption, color: Color = .secondary) -> Text {
        let prefix = prefix.isEmpty ? "" : prefix + " "
        let suffix = suffix.isEmpty ? "" : " " + suffix
        return Text(prefix).font(font).foregroundStyle(color) + self + Text(suffix).font(font).foregroundStyle(color)
    }
}
