import SwiftUI
import BigIntExtensions

// FIXME: 削除予定
public struct SumItemValueButton<Content: View>: View {
    var iconSystemName: String
    var iconColor: Color
    var title: String
    var disabled: Bool
    var action: () -> Void
    var content: Content
    public init(
        iconSystemName: String,
        iconColor: Color,
        title: String,
        disabled: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.title = title
        self.disabled = disabled
        self.action = action
        self.content = content()
    }
    public var body: some View {
        Button {
            action()
        } label: {
            HStack {
                SystemIcon(systemName: iconSystemName, color: iconColor, size: 18)
                    .foregroundStyle(.white)
                    .opacity(disabled ? 0.2 : 1)
                content
            }
            .foregroundStyle(disabled ? Color(uiColor: .secondaryLabel) : Color(uiColor: .label))
            .background {
//                UnevenRoundedRectangle(
//                    cornerRadii: .init(
//                        topLeading: 10.0,
//                        bottomLeading: 30.0,
//                        bottomTrailing: 10.0,
//                        topTrailing: 30.0),
//                    style: .continuous
//                )
//                RoundedRectangle(cornerRadius: 5, style: .continuous)
//                    .foregroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
//                    .shadow(color: Color.black.opacity(0.1), radius: 10)
//                .stroke(style: .init())
            }
        }
        .disabled(disabled)
    }
}

@ViewBuilder
@MainActor
private func content(_ fraction: BFraction, _ unitName: String) -> some View {
    HStack(alignment: .lastTextBaseline, spacing: 5) {
        BFractionText(fraction: fraction, textStyle: .body)
        Text(unitName)
            .font(.caption)
    }
}

#Preview {
    VStack {
        Spacer()
        Color.blue.clipShape(Circle())
            .frame(width: 22, height: 22)
            .overlay {
                Image(systemName: "folder")
                    .resizable()
                    .bold()
                    .scaledToFill()
                    .frame(width: 11, height: 11)
            }
        SystemIcon(systemName: "folder", color: .red, size: 40)
        SystemIcon(systemName: "folder", color: .red, size: 100)
        SumItemValueButton(iconSystemName: "folder", iconColor: .cyan, title: "単価") {
            // do nothing
        } content: {
            content(.init(0, 1), "円")
        }

        SumItemValueButton(iconSystemName: "plus.circle", iconColor: .indigo, title: "単価", disabled: true) {
            // do nothing
        } content:  {
            VStack {
                Text("どすこい")
                Text("どすこい")
            }
        }

        SumItemValueButton(iconSystemName: "note", iconColor: .purple, title: "単価") {
            // do nothing
        } content:  {
            content(.init(10000, 3), "円")
        }

        SumItemValueButton(iconSystemName: "chevron.down", iconColor: .green, title: "単価") {
            // do nothing
        } content:  {
            content(.init(10000000000, 3), "円/ケース")
        }
        .foregroundStyle(.red)
        HStack {

                SumItemValueButton(iconSystemName: "folder", iconColor: .cyan, title: "単価") {
                    // do nothing
                } content: {
                    content(.init(0, 1), "円")
                }

                SumItemValueButton(iconSystemName: "plus.circle", iconColor: .indigo, title: "単価") {
                    // do nothing
                } content:  {
                    VStack {
                        Text("どすこい")
                        Text("どすこい")
                    }
                }

                SumItemValueButton(iconSystemName: "note", iconColor: .purple, title: "単価") {
                    // do nothing
                } content:  {
                    content(.init(10000, 3), "円")
                }

                SumItemValueButton(iconSystemName: "chevron.down", iconColor: .green, title: "単価") {
                    // do nothing
                } content:  {
                    content(.init(10000000000, 3), "円/ケース")
                }
                .foregroundStyle(.red)
        }
        Spacer()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
