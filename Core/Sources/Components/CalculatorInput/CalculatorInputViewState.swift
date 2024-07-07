import BigInt
import Observation

struct Operating {
    var fraction: BFraction
    var operation: ArithmeticOperation
}
enum  CurrentState {
    case edit(String)
    case fraction(BFraction)
    var isZero: Bool { display == "0" }
    var display: String {
        switch self {
        case .edit(let text): text
        case .fraction(let fraction): fraction.ex.asDecimalString(max: 20)
        }
    }
    func fraction() -> BFraction {
        switch self {
        case .fraction(let fraction): return fraction
        case .edit(let editingValue):
            guard editingValue.contains(".") else {
                return BFraction(Int(editingValue) ?? 0, 1)
            }
            let strings = editingValue.split(separator: ".")
            let ints = strings.map { Int($0) ?? 0 }
            guard ints.count == 2 else {
                return BFraction(Int(ints[0]), 1)
            }
            let numericPart = BFraction(ints[0], 1)
            var nod = 1
            for _ in (0..<strings[1].count) {
                nod *= 10
            }
            let fractionPart = BFraction(ints[1], nod)
            print("ints", ints, editingValue, nod, numericPart, fractionPart, numericPart + fractionPart)
            return numericPart + fractionPart
        }
    }
}

@MainActor
@Observable
final class CalculatorInputViewState {
    private(set) var operating: Operating?
    private(set) var state: CurrentState
    init(operating: Operating? = nil, state: CurrentState) {
        self.operating = operating
        self.state = state
    }
    var buttonTypes: [[ButtonType]] {
        [
            [state.isZero ? .allClear : .clear, .backSpace, .percent, .operation(.division)],
            [.digit(.seven), .digit(.eight), .digit(.nine), .operation(.multiplication)],
            [.digit(.four), .digit(.five), .digit(.six), .operation(.subtraction)],
            [.digit(.one), .digit(.two), .digit(.three), .operation(.addition)],
            [.digit(.zero), .decimal, .equals]
        ]
    }
    func onTap(_ buttonType: ButtonType) {
        print(buttonType.description)
        switch buttonType {
        case .operation(let arithmeticOperation):
            let fraction = if let operating {
                if state.isZero {
                    operating.fraction
                } else {
                    operating.operation.operate(operating.fraction, state.fraction())
                }
            } else {
                state.fraction()
            }
            operating = Operating(fraction: fraction, operation: arithmeticOperation)
            state = .edit("0")
        case .digit(let digit):
            guard !state.isZero else {
                state = .edit(digit.description)
                return
            }
            state = .edit(state.display + digit.description)
        case .decimal:
            guard !state.display.contains(".") else {
                return
            }
            state = .edit(state.display + ".")
        case .equals:
            guard let operating else { return }
            state = .fraction(operating.operation.operate(operating.fraction, state.fraction()))
            self.operating = nil
        case .backSpace:
            let value = state.display.dropLast()
            state = .edit(value.isEmpty ? "0" : String(value))
        case .allClear:
            state = .edit("0")
            operating = nil
        case .clear:
            state = .edit("0")
        case .percent:
            state = .fraction(state.fraction()/100)
        }
    }
}
