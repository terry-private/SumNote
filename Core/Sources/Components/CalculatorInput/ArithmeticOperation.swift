import BigIntExtensions
enum ArithmeticOperation: CaseIterable, CustomStringConvertible {
    case addition, subtraction, multiplication, division

    var description: String {
        switch self {
        case .addition:
            return "+"
        case .subtraction:
            return "−"
        case .multiplication:
            return "×"
        case .division:
            return "÷"
        }
    }
    func operate(_ lhs: BFraction, _ rhs: BFraction) -> BFraction {
        switch self {
        case .addition: lhs + rhs
        case .subtraction: lhs - rhs
        case .multiplication: lhs * rhs
        case .division: lhs / rhs
        }
    }
}
