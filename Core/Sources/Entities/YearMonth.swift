import struct Foundation.Date
import struct Foundation.Calendar

public struct YearMonth: Codable, Sendable, Hashable, Equatable {
    public var year: Int
    public var month: Int
    
    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }
    
    public init(date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
    }
}

extension YearMonth: Identifiable {
    public var id: Int {
        return year * 100 + month
    }
}

extension YearMonth: SectionHeader {
    public var title: String { "\(year)年 \(month)月" }
}

extension YearMonth: Comparable {
    public static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
        lhs.id < rhs.id
    }
}
