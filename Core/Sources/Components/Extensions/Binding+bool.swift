import SwiftUI

extension Binding where Value == Bool {
    @MainActor
    public init<T>(from optionalBinding: Binding<T?>) {
        self.init {
            optionalBinding.wrappedValue != nil
        } set: {
            if !$0 {
                optionalBinding.wrappedValue = nil
            }
        }
    }
}

