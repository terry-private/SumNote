import SwiftUI
import Entities

enum EditState {
    case text(EditTextAlertState)
    case fraction(EditFractionState)
    case discount(EditDiscountState)
    case group(SumGroup.ID)

    var textState: EditTextAlertState? {
        if case .text(let state) = self {
            state
        } else {
            nil
        }
    }
    var fractionState: EditFractionState? {
        if case .fraction(let state) = self {
            state
        } else {
            nil
        }
    }
    var discountState: EditDiscountState? {
        if case .discount(let state) = self {
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
}
