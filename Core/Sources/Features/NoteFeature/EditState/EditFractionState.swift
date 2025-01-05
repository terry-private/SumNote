import SwiftUI
import Entities
import BigIntExtensions

struct EditFractionState: Identifiable {
    var id: String
    var title: String
    var fraction: BFraction
    var completion: (BFraction) -> Void
}

extension Binding where Value == EditFractionState? {
    @MainActor
    init(from editState: Binding<EditState?>) {
        self = Binding<EditFractionState?> {
            editState.wrappedValue?.fractionState
        } set: { state in
            editState.wrappedValue = state.map { .fraction($0) }
        }
    }
}
