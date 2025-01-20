import SwiftUI

public struct TrailingTextField<FocusValue: Hashable>: View {
    @Binding var text: String
    let placeholder: LocalizedStringKey
    var focuseState: FocusState<FocusValue>.Binding
    let equals: FocusValue
    public init(_ placeholder: LocalizedStringKey, text: Binding<String>, focuseState: FocusState<FocusValue>.Binding, equals: FocusValue) {
        _text = text
        self.placeholder = placeholder
        self.focuseState = focuseState
        self.equals = equals
    }
    public var body: some View {
        ZStack(alignment: .trailing) {
            Text(text.isBlank() ? placeholder : "")
                .foregroundStyle(.secondary)
                .padding(5)
            Text(text)
                .foregroundStyle(.primary)
                .padding(5)
                .overlay {
                    HStack {
                        Spacer()
                            .layoutPriority(1)
                        TextField("", text: $text)
                            .textInputAutocapitalization(.never)
                            .focused(focuseState, equals: equals)
                            .foregroundStyle(.clear)
                            .frame(minWidth: 3)
                    }
                    .padding(5)
                }

        }
        .frame(width: .infinity)
        .onTapGesture {
            focuseState.wrappedValue = equals
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @FocusState var focused: Bool
    TrailingTextField("name a", text: $text, focuseState: $focused, equals: true)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 40)
        .border(Color.gray)
        .padding()
}
