import SwiftUI
import Entities

public extension View {
    func removeItemAlert(_ screenState: Binding<ScreenState?>, removeAction: @escaping (SumItem) -> Void) -> some View {
        alert(
            "アイテムを削除",
            isPresented: screenState.removeItemAlertState,
            presenting: screenState.wrappedValue?.removeItem
        ) { item in
            Button("キャンセル", role: .cancel) {
                screenState.wrappedValue = nil
            }
            Button("削除", role: .destructive) {
                removeAction(item)
            }
        } message: { item in
            Text("\(item.name)を削除しますか？")
        }
    }
}
