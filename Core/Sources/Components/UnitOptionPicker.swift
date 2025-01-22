import Entities
import SwiftUI

public struct UnitOptionPcker: View {
    enum Item: Hashable, Identifiable {
        case none
        case unitOption(UnitOption)

        var id: String {
            name
        }

        var name: String {
            switch self {
            case .none:
                return "デフォルト"
            case .unitOption(let unitOption):
                return unitOption.name
            }
        }
    }

    @Binding var item: Item
    var items: [Item]

    public init(_ unitOption: Binding<UnitOption?>, unitOptions: [UnitOption]) {
        self._item = .init {
            unitOption.wrappedValue.map { Item.unitOption($0) } ?? .none
        } set: {
            if case let .unitOption(selectedUnitOption) = $0 {
                unitOption.wrappedValue = selectedUnitOption
            } else {
                unitOption.wrappedValue = nil
            }
        }
        self.items = [.none] + unitOptions.map { Item.unitOption($0) }
    }

    public var body: some View {
        Picker("商品タイプ", selection: $item) {
            ForEach(items, id: \.id) { targetItem in
                Text(targetItem.name)
                    .tag(targetItem)
            }
        }
    }
}

#Preview {
    @Previewable @State var unitOption: UnitOption? = nil
    UnitOptionPcker($unitOption, unitOptions: [.g100])
}
