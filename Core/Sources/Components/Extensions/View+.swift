import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public extension View {
    func onChangeFrame( _ block: @Sendable @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader {
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: $0.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: block)
    }
}

#Preview {
    let hello = Text("\(Text("h"))\(Text("e"))\(Text("l"))\(Text("l"))\(Text("o"))")
    let a = Text("aaaaaaa")
        .font(.largeTitle)
        .foregroundStyle(.purple)
    let b = Text("bbbbbbbb")
        .font(.body)
        .foregroundStyle(.blue)
    let c = Text("ccccccccccccccccccccccccccc")
        .font(.title)
        .foregroundStyle(.green)
    let d = Text("ddddddddd")
        .font(.caption)
        .foregroundStyle(.red)
    let e = Text("eeeeeeeee")
        .font(.title)
        .foregroundStyle(.yellow)
    Text("\(hello)\(a) \(b) \(c) \(d) \(e)")
        .padding()
        .border(Color.pink, width: 2)
}
