import Entities

public struct EditItemState: Identifiable {
    public var id: SumItem.ID { item.id }
    public var item: SumItem
    public var mode: EditItemView.Mode
    public init(item: SumItem, mode: EditItemView.Mode) {
        self.item = item
        self.mode = mode
    }
}
