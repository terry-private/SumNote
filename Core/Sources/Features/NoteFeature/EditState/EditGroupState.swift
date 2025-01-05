import SwiftUI
import Entities

struct EditGroupState: Identifiable, Hashable {
    static func == (lhs: EditGroupState, rhs: EditGroupState) -> Bool {
        lhs.group.wrappedValue == rhs.group.wrappedValue
    }

    var id: SumGroup2.ID { group.id }
    var group: Binding<SumGroup2>
    var hashValue: Int { group.wrappedValue.hashValue }
    func hash(into hasher: inout Hasher) {
        hasher.combine(group.wrappedValue)
    }
}

extension Binding where Value == EditGroupState? {
    @MainActor
    init(from editState: Binding<EditState?>) {
        self = Binding<EditGroupState?> {
            editState.wrappedValue?.groupState
        } set: { state in
            editState.wrappedValue = state.map { .group($0) }
        }
    }
}
