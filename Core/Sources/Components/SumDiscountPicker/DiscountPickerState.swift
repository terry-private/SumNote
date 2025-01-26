import SwiftUI
import Entities

public struct DiscountPickerState: Identifiable {
    public var id: SumDiscount.ID { discount.id }
    public var title: String
    public var discount: SumDiscount
    public var completion: (SumDiscount) -> Void
    public init(title: String, discount: SumDiscount, completion: @escaping (SumDiscount) -> Void) {
        self.title = title
        self.discount = discount
        self.completion = completion
    }
}

extension View {
    public func discountPckerSheet(_ item: Binding<DiscountPickerState?>) -> some View {
        background {
            GeometryReader { proxy in
                let size = DiscountLayoutLogics.displaySize(maxSize: proxy.size)
                Color.clear
                    .sheet(item: item) { state in
                        DiscountPicker(state) {
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
