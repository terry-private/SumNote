import SwiftUI
import BigInt

public struct BFractionText: View {
    let fraction: BFraction
    let textStyle: Font.TextStyle
    let rounded: Int
    public init(fraction: BFraction, textStyle: Font.TextStyle = .body, rounded: Int = 2) {
        self.fraction = fraction
        self.textStyle = textStyle
        self.rounded = rounded
    }
    var wholePartFont: UIFont {
        textStyle.uiFont
    }
    var fractionalPartFont: UIFont {
        .systemFont(ofSize: wholePartFont.xHeight * wholePartFont.pointSize / wholePartFont.capHeight)
    }
    var wholePart: String {
        fraction.truncate().description
    }
    var fractionalPart: String {
        fraction.asDecimalString(precision: rounded + wholePart.count).split(separator: ".")[1].description
    }
    var currencyWholePart: String {
        let string = wholePart
        var result = ""
        let lastIndex = string.count - 1
        for (index, char) in string.enumerated() {
            if index > 0 && (lastIndex - index + 1) % 3 == 0 {
                result.append(",")
            }
            result.append(char)
        }
        return result
    }
    public var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            if fraction.denominator != 1 {
                
                Text(currencyWholePart)
                    .font(.init(wholePartFont)) +
                Text(".") +
                Text(fractionalPart)
                    .font(.init(fractionalPartFont))
            } else {
                Text(currencyWholePart)
                    .font(.init(wholePartFont))
            }
        }
        .textSelection(.enabled)
        .lineLimit(1)
        .monospacedDigit()
    }
}

#Preview {
    VStack {
        BFractionText(fraction: BFraction(30000,7))
            .foregroundStyle(Color.cyan)
            .bold()
    }
}
