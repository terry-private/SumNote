import SwiftUI
import Entities

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
    public var removeGroup: SumGroup? {
        if case .removeGroup(let group) = self {
            group
        } else {
            nil
        }
    }
    public func isShow(_ target: SumItem) -> Bool {
        switch self {
            case .item(let state):
            state.id == target.id
        case .fraction(let state):
            state.id == target.id
        case .discount(let state):
            state.id == target.discount.id
        case .removeItem(let item):
            item.id == target.id
        case .text, .group, .removeGroup:
            false
        }
    }
    public func isShow(_ target: SumGroup) -> Bool {
        switch self {
        case .group(let id):
            id == target.id
        case .removeGroup(let group):
            group.id == target.id
        case .item, .fraction, .discount, .removeItem, .text:
            false
        }
    }
}

// MARK: - calculatorInputState
public extension Binding where Value == ScreenState? {
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
public extension Binding where Value == ScreenState? {
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
public extension Binding where Value == ScreenState? {
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
public extension Binding where Value == ScreenState? {
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
public extension Binding where Value == ScreenState? {
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
