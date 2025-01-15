import SwiftUI
import Entities

struct EditTextAlertState: Identifiable {
    var id: String
    var title: String
    var text: String
    var completion: (String) -> Void
    init(id: String, title: String, text: String, completion: @escaping (String) -> Void) {
        self.id = id
        self.title = title
        self.text = text
        self.completion = completion
    }
    init(title: String, item: Binding<SumItem>,_ keyPath: WritableKeyPath<SumItem, String>) {
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

extension Binding where Value == Bool {
    @MainActor
    init(from alertState: Binding<EditState?>) {
        self.init {
            return alertState.wrappedValue?.textState != nil
        } set: {
            if !$0 {
                alertState.wrappedValue = nil
            }
        }
    }
}
struct EditTextAlert: View {
    @State var tmpText: String?
    @Binding var editState: EditState?
    init(editState: Binding<EditState?>) {
        _tmpText = .init(wrappedValue: editState.wrappedValue?.textState?.text)
        self._editState = editState
    }
    var body: some View {
        EmptyView()
            .alert(
                editState?.textState?.title ?? "",
                isPresented: .init(from: $editState),
                presenting: editState?.textState
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

extension View {
    func editTextAlert(editState: Binding<EditState?>) -> some View {
        background {
            EditTextAlert(editState: editState)
        }
    }
}
