import Foundation

public enum DateString {
    public static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter
    }()

    public static func format(from date: Date, _ formatter: DateFormatter = customFormatter) -> String {
        formatter.string(from: date)
    }
    public static func humanize(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "H:mm"
            return timeFormatter.string(from: date)
        }

        if calendar.isDateInYesterday(date) {
            return "昨日"
        }

        let dateYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)
        let weekComponent = calendar.dateComponents([.weekOfYear], from: date, to: now)

        if let weekOfYear = weekComponent.weekOfYear, weekOfYear == 0 {
            let dayFormatter = DateFormatter()
            dayFormatter.locale = Locale(identifier: "ja_JP")
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: date)
        }

        if dateYear == currentYear {
            let monthDayFormatter = DateFormatter()
            monthDayFormatter.dateFormat = "M/d"
            return monthDayFormatter.string(from: date)
        }

        let yearMonthDayFormatter = DateFormatter()
        yearMonthDayFormatter.dateFormat = "y/M/d"
        return yearMonthDayFormatter.string(from: date)
    }
}
