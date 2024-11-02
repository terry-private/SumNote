import SwiftUI
import BigIntExtensions

public struct BFractionText: View {
    let fraction: BFraction
    let textStyle: Font.TextStyle
    let rounded: Int
    let currencyMode: Bool
    public init(fraction: BFraction, textStyle: Font.TextStyle = .body, rounded: Int = 2, currencyMode: Bool = true) {
        self.fraction = fraction
        self.textStyle = textStyle
        self.rounded = rounded
        self.currencyMode = currencyMode
    }
    var wholePartFont: UIFont {
        textStyle.uiFont
    }
    var fractionalPartFont: UIFont {
        .systemFont(ofSize: wholePartFont.xHeight * wholePartFont.pointSize / wholePartFont.capHeight)
    }
    public var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            let wholePart = currencyMode ? fraction.ex.currencyWholePartString : fraction.ex.wholePartString
            if fraction.denominator != 1 {
                Text(wholePart)
                    .font(.init(wholePartFont)) +
                Text(".") +
                Text(fraction.ex.fractionalPartString(rounded: rounded))
                    .font(.init(fractionalPartFont))
            } else {
                Text(wholePart)
                    .font(.init(wholePartFont))
            }
        }
        .textSelection(.enabled)
        .lineLimit(1)
        .monospacedDigit()
    }
}

extension BFraction {
    func hasRepeatingDecimal() -> Bool {
        var log2 = 0
        var log5 = 0
        // 分母の素因数を2と5以外のものに分解
        var denominator = denominator
        while denominator % 2 == 0 {
            denominator /= 2
            log2 += 1
        }
        while denominator % 5 == 0 {
            denominator /= 5
            log5 += 1
        }
        // 残りの分母が1でない場合、循環小数になる
        return denominator != 1
    }
}

#Preview {
    VStack {
        BFractionText(fraction: BFraction(30000,14), rounded: 4)
            .foregroundStyle(Color.cyan)
            .bold()
        BFractionText(fraction: BFraction(30000,14), rounded: 4, currencyMode: false)
            .foregroundStyle(Color.cyan)
            .bold()
    }
}
