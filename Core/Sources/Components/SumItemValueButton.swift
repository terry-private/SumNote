import SwiftUI
import BigIntExtensions

public struct SumItemValueButton<Content: View>: View {
    var title: String
    var action: () -> Void
    var content: Content
    public init(title: String, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.action = action
        self.content = content()
    }
    public var body: some View {
        Button {

        } label: {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption2)
                content
                .padding(.leading, 15)
            }
            .foregroundStyle(.white)
            .padding(5)
            .background {
//                UnevenRoundedRectangle(
//                    cornerRadii: .init(
//                        topLeading: 10.0,
//                        bottomLeading: 30.0,
//                        bottomTrailing: 10.0,
//                        topTrailing: 30.0),
//                    style: .continuous
//                )
                RoundedRectangle(cornerRadius: 5, style: .continuous)
//                .stroke(style: .init())
            }
        }
    }
}

@ViewBuilder
@MainActor
func content(_ fraction: BFraction, _ unitName: String) -> some View {
    HStack(alignment: .lastTextBaseline, spacing: 5) {
        BFractionText(fraction: fraction, textStyle: .body)
        Text(unitName)
            .font(.caption)
    }
}

#Preview {
    HStack {
        SumItemValueButton(title: "単価") {
            // do nothing
        } content: {
            content(.init(0, 1), "円")
        }

        SumItemValueButton(title: "単価") {
            // do nothing
        } content:  {
            VStack {
                Text("どすこい")
                Text("どすこい")
            }
        }

        SumItemValueButton(title: "単価") {
            // do nothing
        } content:  {
            content(.init(10000, 3), "円")
        }

        SumItemValueButton(title: "単価") {
            // do nothing
        } content:  {
            content(.init(10000000000, 3), "円/ケース")
        }
        .foregroundStyle(.red)
    }
}
