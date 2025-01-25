import SwiftUI
import Entities

public extension Binding where Value == SumGroup.ID? {
    @MainActor
    init(from screenState: Binding<ScreenState?>) {
        self = Binding<SumGroup.ID?> {
            screenState.wrappedValue?.groupID
        } set: { state in
            screenState.wrappedValue = state.map { .group($0) }
        }
    }
}
