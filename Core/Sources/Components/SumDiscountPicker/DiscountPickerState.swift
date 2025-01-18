import SwiftUI
import Entities

public struct DiscountPickerState: Identifiable {
    public var id: SumOption.ID { option.id }
    public var title: String
    public var option: SumOption
    public var completion: (SumOption) -> Void
    public init(title: String, option: SumOption, completion: @escaping (SumOption) -> Void) {
        self.title = title
        self.option = option
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
