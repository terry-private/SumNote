import SwiftUI
import Entities
import Components

enum EditState {
    case text(EditTextAlertState)
    case fraction(CalculatorInputState)
    case discount(DiscountPickerState)
    case group(SumGroup.ID)
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
extension Binding where Value == EditState? {
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
extension Binding where Value == EditState? {
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
extension Binding where Value == EditState? {
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
extension Binding where Value == EditState? {
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
