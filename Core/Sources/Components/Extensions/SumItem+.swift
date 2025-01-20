import Entities
import SwiftUI

public extension SumItem {
    var tab: Text {
        Text("  ")
    }
    var hasDiscount: Bool {
        option.numerator != .zero
    }
    var discountText: Text {
        Text(option.numerator.description).bold().add(suffix: option.suffix)
    }
    var optionalDiscountText: Text {
        if hasDiscount {
            return Text("(\(discountText))")
        } else {
            return Text("")
        }
    }
    var calculationDescription: Text {
        unitPrice.text().bold().add(suffix: "円/\(unitName)")
        + tab
        + Text("\(Image(systemName: "xmark"))").font(.caption).foregroundStyle(.secondary)
        + tab
        + quantity.text().bold().add(suffix: unitName)
        + tab
        + Text("\(Image(systemName: "equal"))").font(.caption).foregroundStyle(.secondary)
        + tab
        + answer
    }
    var answer: Text {
        if hasDiscount {
            Text("\(subtotal.text().bold())").strikethrough().add(suffix: "円")
        } else {
            Text("\(sum.text().bold())").add(suffix: "円")
        }
    }
}

#Preview {
    VStack {
        let item = SumItem(name: "test item", unitPrice: 1000, quantity: 10, unitName: "個", option: .init(10))
        item.calculationDescription
        item.sum.text().add(prefix: "合計", suffix: "円")
    }
}
