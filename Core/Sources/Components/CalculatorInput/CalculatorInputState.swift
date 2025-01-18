import SwiftUI
import BigIntExtensions
import Entities

public enum FractionalProperty {
    case unitPrice
    case quantity
    public var name: String {
        switch self {
        case .unitPrice:
            "単価"
        case .quantity:
            "数量"
        }
    }
    public var keyPath: WritableKeyPath<SumItem, BFraction> {
        switch self {
        case .unitPrice:
            \.unitPrice
        case .quantity:
            \.quantity
        }
    }
}

public struct CalculatorInputState: Identifiable {
    public var id: SumItem.ID { item.id }
    public var item: SumItem
    public var property: FractionalProperty
    public var fraction: BFraction
    public var completion: (BFraction) -> Void
    public init(item: SumItem, property: FractionalProperty, completion: @escaping (BFraction) -> Void) {
        self.item = item
        self.property = property
        self.fraction = item[keyPath: property.keyPath]
        self.completion = completion
    }

    var title: String {
        "\(item.name) / \(property.name)"
    }
}

extension View {
    public func caluculatorInputSheet(_ item: Binding<CalculatorInputState?>) -> some View {
        background {
            GeometryReader { proxy in
                let size = CalculatorLayoutLogics.displaySize(maxSize: proxy.size)
                Color.clear
                    .sheet(item: item) { state in
                        CalculatorInputView(
                            title: state.title,
                            value: state.fraction,
                            size: size,
                            completion: state.completion
                        ) {
                            item.wrappedValue = nil
                        }
                        .presentationDetents(
                            [.height(size.height)]
                        )
                    }
            }
        }
    }
}
