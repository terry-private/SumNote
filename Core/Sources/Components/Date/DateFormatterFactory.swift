import Foundation

public enum DateString {
    public static let mediumFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        // 時刻の自動フォーマットスタイル
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    public static func from(_ date: Date, formatter: DateFormatter = mediumFormatter) -> String {
        formatter.string(from: date)
    }
}
