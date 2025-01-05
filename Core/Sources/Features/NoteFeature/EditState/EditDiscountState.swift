import SwiftUI
import Entities

struct EditDiscountState: Identifiable {
    var id: SumOption.ID { option.id }
    var title: String
    var option: SumOption
    var completion: (SumOption?) -> Void
}
