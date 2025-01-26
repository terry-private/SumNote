import Entities

public struct EditItemState: Identifiable {
    public enum Mode {
        case create
        case edit
        public var title: String {
            switch self {
            case .create: "新規作成"
            case .edit: "編集"
            }
        }
    }
    public var id: SumItem.ID { item.id }
    public var item: SumItem
    public var mode: Mode
    public init(item: SumItem, mode: Mode) {
        self.item = item
        self.mode = mode
    }
}
