import BigIntExtensions
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
        case .fraction(let fraction): fraction.ex.decimalString(max: 20)
        }
    }
    func fraction() -> BFraction {
        switch self {
        case .fraction(let fraction): return fraction
        case .edit(var editingValue):
            print("editingValue:", editingValue)
            if editingValue.last == "." {
                editingValue = String(editingValue.dropLast())
            }
            print("editingValue:", editingValue)
            return BFraction(editingValue) ?? BFraction(0, 1)
        }
    }
}

@MainActor
@Observable
final class CalculatorInputViewState {
    private(set) var operating: Operating?
    private(set) var state: CurrentState
    let completion: (BFraction) -> Void
    let cancel: () -> Void
    init(operating: Operating? = nil, state: CurrentState, completion: @escaping (BFraction) -> Void, cancel: @escaping () -> Void) {
        self.operating = operating
        self.state = state
        self.completion = completion
        self.cancel = cancel
    }
    var buttonTypes: [[ButtonType]] {
        [
            [state.isZero ? .allClear : .clear, .backSpace, .percent, .operation(.division)],
            [.digit(.seven), .digit(.eight), .digit(.nine), .operation(.multiplication)],
            [.digit(.four), .digit(.five), .digit(.six), .operation(.subtraction)],
            [.digit(.one), .digit(.two), .digit(.three), .operation(.addition)],
            [.digit(.zero), .decimal, operating == nil ? .done : .equals]
        ]
    }
    func onTap(_ buttonType: ButtonType) {
        switch buttonType {
        case .operation(let arithmeticOperation):
            print("arithmeticOperation", arithmeticOperation)
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
            guard operating.operation != .division || !state.fraction().isZero else { return } // 0で割ろうとするなら無視
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
        case .done:
            completion(state.fraction())
        }
    }
    func add1() {
        state = .fraction(state.fraction() + 1)
    }
    func subtract1() {
        state = .fraction(state.fraction() - 1)
    }
}
