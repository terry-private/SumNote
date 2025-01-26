import SwiftUI

public struct SystemIcon: View {
    var systemName: String
    var color: Color
    var size: CGFloat
    public init(systemName: String, color: Color, size: CGFloat) {
        self.systemName = systemName
        self.color = color
        self.size = size
    }
    public var body: some View {
        color.clipShape(Circle())
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: systemName)
                    .resizable()
                    .bold()
                    .scaledToFill()
                    .frame(width: size/2, height: size/2)
            }
    }
}

#Preview {
    SystemIcon(systemName: "heart", color: .red, size: 50)
    SystemIcon(systemName: "star.fill", color: .yellow, size: 80)
    SystemIcon(systemName: "chevron.down", color: .blue, size: 100)
}
