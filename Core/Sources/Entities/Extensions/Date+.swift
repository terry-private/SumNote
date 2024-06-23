import Foundation

public extension Date {
    static var dummy: Self {
        return Date(timeIntervalSinceNow: TimeInterval((1...10).randomElement()!) * TimeInterval([1, 7, 30, 365].randomElement()!) * TimeInterval(-60*60*24))
    }
}

