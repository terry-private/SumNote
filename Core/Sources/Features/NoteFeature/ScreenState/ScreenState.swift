import SwiftUI
import Entities
import Components

public enum ScreenState {
    case text(EditTextAlertState)
    case fraction(CalculatorInputState)
    case discount(DiscountPickerState)
    case group(SumGroup.ID)
    case item(EditItemState)
    case removeGroup(SumGroup)
    case removeItem(SumItem)

    var textState: EditTextAlertState? {
        if case .text(let state) = self {
            state
        } else {
            nil
        }
    }
    var groupID: SumGroup.ID? {
        if case .group(let id) = self {
            id
        } else {
            nil
        }
    }
    var removeItem: SumItem? {
        if case .removeItem(let item) = self {
            item
        } else {
            nil
        }
    }
    var removeGroup: SumGroup? {
        if case .removeGroup(let group) = self {
            group
        } else {
            nil
        }
    }
}

// MARK: - calculatorInputState
extension Binding where Value == ScreenState? {
    @MainActor
    var calculatorInputState: Binding<CalculatorInputState?> {
        Binding<CalculatorInputState?> {
            if case .fraction(let state) = wrappedValue {
                state
            } else {
                nil
            }
        } set: { state in
            wrappedValue = state.map { .fraction($0) }
        }
    }
}

// MARK: - discountPickerState
extension Binding where Value == ScreenState? {
    @MainActor
    var discountState: Binding<DiscountPickerState?> {
        Binding<DiscountPickerState?> {
            if case .discount(let state) = wrappedValue {
                state
            } else {
                nil
            }
        } set: { state in
            wrappedValue = state.map { .discount($0) }
        }
    }
}

// MARK: - removeItemAlertState
extension Binding where Value == ScreenState? {
    @MainActor
    var removeItemAlertState: Binding<Bool> {
        Binding<Bool> {
            wrappedValue?.removeItem != nil
        } set: {
            if !$0 {
                wrappedValue = nil
            }
        }
    }
}

// MARK: - removeGroupAlertState
extension Binding where Value == ScreenState? {
    @MainActor
    var removeGroupAlertState: Binding<Bool> {
        Binding<Bool> {
            wrappedValue?.removeGroup != nil
        } set: {
            if !$0 {
                wrappedValue = nil
            }
        }
    }
}

// MARK: - item
extension Binding where Value == ScreenState? {
    @MainActor
    var item: Binding<EditItemState?> {
        Binding<EditItemState?> {
            if case .item(let state) = wrappedValue {
                state
            } else {
                nil
            }
        } set: { state in
            if let state {
                wrappedValue = .item(state)
            } else {
                wrappedValue = nil
            }
        }
    }
}

extension SumItem {
    func backgroundColor(_ screenState: ScreenState?) -> Color {
        switch screenState {
        case .discount(let state):
            if state.id == discount.id {
                return Color(uiColor: .systemFill)
            }
        case .removeItem(let item):
            if item.id == id {
                return Color.red.opacity(0.7)
            }
        case .fraction(let state):
            if state.id == id {
                return Color(uiColor: .systemFill)
            }
        case .item(let state):
            if state.id == id {
                return Color(uiColor: .systemFill)
            }
        default:
            break
        }
        return Color.clear
    }
}
