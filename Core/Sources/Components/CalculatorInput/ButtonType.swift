import SwiftUI

enum ButtonType: Hashable, CustomStringConvertible {
    case digit(_ digit: Digit)
    case operation(_ operation: ArithmeticOperation)
    case backSpace
    case percent
    case decimal
    case equals
    case allClear
    case clear

    static var calculationButtonTypes: [[ButtonType]] {
        [
            [.allClear, .backSpace, .percent, .operation(.division)],
            [.digit(.seven), .digit(.eight), .digit(.nine), .operation(.multiplication)],
            [.digit(.four), .digit(.five), .digit(.six), .operation(.subtraction)],
            [.digit(.one), .digit(.two), .digit(.three), .operation(.addition)],
            [.digit(.zero), .decimal, .equals]
        ]
    }

    public var description: String {
        switch self {
        case .digit(let digit):
            return digit.description
        case .operation(let operation):
            return operation.description
        case .backSpace:
            return "<"
        case .percent:
            return "%"
        case .decimal:
            return "."
        case .equals:
            return "="
        case .allClear:
            return "AC"
        case .clear:
            return "C"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .allClear, .clear, .backSpace, .percent:
            return Color(.lightGray)
        case .operation, .equals:
            return .orange
        case .digit, .decimal:
            return .secondary
        }
    }

    var foregroundColor: Color {
        switch self {
        case .allClear, .clear, .backSpace, .percent:
            return .black
        default:
            return .white
        }
    }
}
