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
    case done

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
        case .done:
            return "確定"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .allClear, .clear, .backSpace, .percent:
            Color(.lightGray)
        case .operation, .equals:
            .orange
        case .digit, .decimal:
            Color(.darkGray)
        case .done:
            .blue
        }
    }

    var foregroundColor: Color {
        switch self {
        case .allClear, .clear, .backSpace, .percent:
            .black
        default:
            .white
        }
    }
}
