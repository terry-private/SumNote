import SwiftUI
import Entities

extension Binding where Value == SumGroup.ID? {
    @MainActor
    init(from editState: Binding<EditState?>) {
        self = Binding<SumGroup.ID?> {
            editState.wrappedValue?.groupID
        } set: { state in
            editState.wrappedValue = state.map { .group($0) }
        }
    }
}
