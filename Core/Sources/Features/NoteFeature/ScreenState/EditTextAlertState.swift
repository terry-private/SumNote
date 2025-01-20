import SwiftUI
import Entities

public struct EditTextAlertState: Identifiable {
    public var id: String
    public var title: String
    public var text: String
    public var completion: (String) -> Void
    public init(id: String, title: String, text: String, completion: @escaping (String) -> Void) {
        self.id = id
        self.title = title
        self.text = text
        self.completion = completion
    }
    public init(title: String, item: Binding<SumItem>,_ keyPath: WritableKeyPath<SumItem, String>) {
        self.init(
            id: item.id.rawValue,
            title: title,
            text: item.wrappedValue[keyPath: keyPath],
            completion: {
                item.wrappedValue[keyPath: keyPath] = $0
            }
        )
    }
}

public extension Binding where Value == Bool {
    @MainActor
    init(from alertState: Binding<ScreenState?>) {
        self.init {
            return alertState.wrappedValue?.textState != nil
        } set: {
            if !$0 {
                alertState.wrappedValue = nil
            }
        }
    }
}

public struct EditTextAlert: View {
    @State var tmpText: String?
    @Binding var screenState: ScreenState?
    public init(screenState: Binding<ScreenState?>) {
        _tmpText = .init(wrappedValue: screenState.wrappedValue?.textState?.text)
        self._screenState = screenState
    }
    public var body: some View {
        EmptyView()
            .alert(
                screenState?.textState?.title ?? "",
                isPresented: .init(from: $screenState),
                presenting: screenState?.textState
            ) { state in
                TextField("テキストフィールド", text: .init {
                    tmpText ?? state.text
                } set: {
                    tmpText = $0
                })
                Button("Cancel") {
                    self.tmpText = nil
                }
                Button("OK") {
                    guard let tmpText, !tmpText.isBlank() else { return }
                    state.completion(tmpText)
                    self.tmpText = nil
                }
            }
    }
}

public extension View {
    func editTextAlert(screenState: Binding<ScreenState?>) -> some View {
        background {
            EditTextAlert(screenState: screenState)
        }
    }
}
