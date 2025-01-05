import SwiftUI
import BigIntExtensions
import Entities
import CoreProtocols
import Components
import Combine
import Stores

//struct EditAlert2<T> {
//    var title: String
//    var binding: Binding<T>
//}
//struct EditFractionState2: Identifiable {
//    var id: String
//    var title: String
//    var fraction: BFraction
//    var completion: (BFraction) -> Void
//}

struct EditTextAlertState: Identifiable {
    var id: String
    var title: String
    var text: Binding<String>
    var completion: (String) -> Void
}
struct EditGroupState: Identifiable, Hashable {
    static func == (lhs: EditGroupState, rhs: EditGroupState) -> Bool {
        lhs.group.wrappedValue == rhs.group.wrappedValue
    }
    
    var id: SumGroup2.ID { group.id }
    var group: Binding<SumGroup2>
    var hashValue: Int { group.wrappedValue.hashValue }
    func hash(into hasher: inout Hasher) {
        hasher.combine(group.wrappedValue)
    }
}
struct EditDiscountState: Identifiable {
    var id: SumOption.ID { option.id }
    var title: String
    var option: SumOption
    var completion: (SumOption?) -> Void
}

extension Binding where Value == Bool {
    @MainActor
    static func bool(from alertState: Binding<EditStete?>) -> Self {
        Binding<Bool> {
            print(alertState.wrappedValue as Any)
            return alertState.wrappedValue?.textState != nil
        } set: {
            if !$0 {
                alertState.wrappedValue = nil
            }
        }
    }
}
extension Binding where Value == EditFractionState? {
    @MainActor
    static func editFractionState(from editState: Binding<EditStete?>) -> Self {
        Binding<EditFractionState?> {
            editState.wrappedValue?.fractionState
        } set: { state in
            editState.wrappedValue = state.map { .fraction($0)}
        }
    }
}
extension Binding where Value == EditGroupState? {
    @MainActor
    static func editGroupState(from editState: Binding<EditStete?>) -> Self {
        Binding<EditGroupState?> {
            editState.wrappedValue?.groupState
        } set: { state in
            editState.wrappedValue = state.map { .group($0) }
        }
    }
}

enum EditStete {
    case text(EditTextAlertState)
    case fraction(EditFractionState)
    case discount(EditDiscountState)
    case group(EditGroupState)
    var textState: EditTextAlertState? {
        if case .text(let state) = self {
            state
        } else {
            nil
        }
    }
    var fractionState: EditFractionState? {
        if case .fraction(let state) = self {
            state
        } else {
            nil
        }
    }
    var discountState: EditDiscountState? {
        if case .discount(let state) = self {
            state
        } else {
            nil
        }
    }
    var groupState: EditGroupState? {
        if case .group(let state) = self {
            state
        } else {
            nil
        }
    }
}
public struct SumNoteView2<Dependency: DependencyProtocol>: View {
    @Environment(\.editMode) private var editMode
    @State var store = Dependency.noteStore
    @State var note: SumNote2
    @State var editState: EditStete?
    @Namespace private var animationNameSpace
    public init(_ note: SumNote2) {
        _note = .init(wrappedValue: note)
    }
    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { _ in
                List {
                    groups()
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
//                .onChange(of: addedTableID) {
//                    guard let addedTableID else { return }
//                    withAnimation {
//                        scrollProxy.scrollTo(addedTableID)
//                    }
//                }
//                .onChange(of: addedItemID) {
//                    guard let addedItemID else { return }
//                    withAnimation {
//                        scrollProxy.scrollTo(addedItemID)
//                    }
//                }
            }
            // MARK: - 総計 -
            HStack {
                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    Text("総計")
                        .foregroundStyle(.secondary)
                    BFractionText(fraction: note.sum(), textStyle: .title3)
                    Text("円")
                }
                .padding()
                Spacer()
            }
            .ignoresSafeArea()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        // MARK: - Alert -
        .alert(
            editState?.textState?.title ?? "",
            isPresented: .bool(from: $editState),
            presenting: editState?.textState
        ) { textState in
            TextField("テキストフィールド", text: textState.text)
            Button("Cancel", action: {})
            Button("OK") {
                guard !textState.text.wrappedValue.isBlank() else { return }
                textState.completion(textState.text.wrappedValue)
            }
        }
        .sheet(item: .editFractionState(from: $editState)) { state in
            CalculatorInputView(
                title: state.title,
                value: state.fraction,
                completion: state.completion
            ) {
                editState = nil
            }
            .presentationDetents([.height(CalculatorLayoutLogics.displaySize(maxSize: UIScreen.main.bounds.size).height)]
            )
        }
        .overlay {
            if let state = editState?.discountState {
                SumDiscountPicker(title: state.title, option: state.option, completion: state.completion) {
                    editState = nil
                }
            }
        }
        .navigationDestination(item: Binding<EditGroupState?>.editGroupState(from: $editState)) { state in
            SumGroupView(sumGroup: state.group)
        }
        // MARK: - toolbar -
        .toolbar {
            if editMode?.wrappedValue.isEditing == true {
                Button("完了") {
                    withAnimation {
                        editMode?.wrappedValue = .inactive
                    }
                }
            } else {
                Menu {
                    Button("ノート名を編集", systemImage: "square.and.pencil") {
//                        setAlert(title: "表題を編集", binding: $note.name)
                    }
                    Button("グループ編集モード") {
                        withAnimation {
                            editMode?.wrappedValue = .active
                        }
                    }
                    Button("空のグループを追加", systemImage: "note.text.badge.plus") {
                        withAnimation {
//                            let newTable = SumGroup(name: "グループ\(note.groups.count+1)", items: [.init(name: "アイテム", unitPrice: 0, quantity: 0, unitName: "個")])
//                            note.groups.append(newTable)
//                            addedTableID = newTable.id
                        }
                    }
                    Button("テキストコピー", systemImage: "pencil") {
                        UIPasteboard.general.string = note.description()
                    }
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
                .disabled(editState?.discountState != nil)
            }
        }
        // MARK: - navigationTitle -
        .navigationTitle(note.name)
        // MARK: - onChange -
//        .onChange(of: note) {
//            Task { @MainActor in
//                try await store.update(note)
//            }
//        }
    }
}

// MARK: - set alert -
extension SumNoteView2 {
//    func setAlert(title: String, binding: Binding<String>) {
//        editNameAlert = nil
//        Task { @MainActor in
//            editNameAlertText = binding.wrappedValue
//            editNameAlert = .init(title: title, binding: binding)
//        }
//    }
}

// MARK: - ViewBuilders -
extension SumNoteView2 {
    @ViewBuilder
    func groups() -> some View {
        ForEach($note.rows) { $row in
            if editMode?.wrappedValue.isEditing == true {
                VStack {
                    HStack {
                        if row.isGroup {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .bold()
                                .padding(5)
                                .background(Color.orange.clipShape(Circle()))
                                .foregroundStyle(.white)
                        }
                        Text(row.name)
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("合計")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            BFractionText(fraction: row.sum())
                            Text("円")
                                .font(.caption)
                        }
                    }
                }
            } else {
                switch row {
                case .group(let group):
                    Button {
                        guard editState == nil else { return }
                        editState = .group(
                            .init(
                                group: .init {
                                    group
                                } set: {
                                    row = .group($0)
                                }
                            )
                        )
                    } label: {
                        HStack(spacing: 10) {
                            SystemIcon(systemName: "note.text", color: .orange, size: 22)
                                .foregroundStyle(.white)
                            Text(group.name)
                            if let (totalQuantity, unitName) = group.totalQuantity() {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("(")
                                    BFractionText(fraction: totalQuantity)
                                    Text(unitName)
                                        .font(.caption)
                                    Text(")")
                                }
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 5) {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("合計")
                                        .font(.caption)
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    BFractionText(fraction: group.sum())
                                    Text("円")
                                        .font(.caption)
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                            }
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(Color(uiColor: .label))
                    .buttonStyle(BorderlessButtonStyle())
                case .item(let item):
                    SumItemView(
                        item: Binding<SumItem2> {
                            item
                        } set: {
                            row = .item($0)
                        },
                        state: $editState
                    )
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
//        .onMove { indexSet, index in
//            note.rows.move(fromOffsets: indexSet, toOffset: index)
//        }
//        .onDelete { indexSet in
//            note.rows.remove(atOffsets: indexSet)
//        }
    }

    // MARK: - header footer -
//    @ViewBuilder
//    func header(table: Binding<SumGroup>) -> some View {
//        HStack(alignment: .lastTextBaseline) {
//            Menu {
//                Button("空のアイテムを追加", systemImage: "square.badge.plus") {
//                    withAnimation {
//                        let item: SumItem = .init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個")
//                        table.wrappedValue.items.append(item)
////                        addedItemID = item.id
//                    }
//                }
//                Button("テンプレートから追加", systemImage: "macwindow.badge.plus") {
//
//                }
//            } label: {
//                Image(systemName: "plus")
//                    .padding(15) // タップ範囲を広げる
//            }
//            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
//            .padding(.trailing, 20)
//
//            Menu {
//                Button("グループ名を編集", systemImage: "square.and.pencil") {
//                    setAlert(title: "表題を編集", binding: table.name)
//                }
//                Button("テキストコピー", systemImage: "pencil") {
//                    UIPasteboard.general.string = table.wrappedValue.description()
//                }
//            } label: {
//                Text(table.wrappedValue.name)
//                    .font(.title3)
//                    .padding(20) // タップ範囲を広げる
//            }
//            .padding(-16) // タップ範囲を広げてもレイアウトサイズはそのままにする
//            Spacer()
//            Text("合計")
//                .font(.caption)
//            BFractionText(fraction: table.wrappedValue.sum, textStyle: .title3, rounded: 2)
//                .foregroundStyle(Color(uiColor: .label))
//                .bold()
//            Text("円")
//                .font(.caption)
//        }
//        .listRowSeparator(.hidden)
//    }
//    func footer(table: Binding<SumGroup>) -> some View {
//        HStack {
//            Spacer()
//            Menu {
//                Button("空のアイテムを追加", systemImage: "square.badge.plus") {
//                    withAnimation {
//                        table.wrappedValue.items.append(.init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個"))
//                    }
//                }
//                Button("テンプレートから追加", systemImage: "macwindow.badge.plus") {
//
//                }
//            } label: {
//                Image(systemName: "plus")
//                    .padding(15) // タップ範囲を広げる
//            }
//            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
//            Spacer()
//        }
//    }

    // MARK: - table row -
//    @ViewBuilder
//    func tableRow(tableName: String, _ row: Binding<SumItem>) -> some View {
//        let showDetail: Bool = showDetails.contains(row.wrappedValue.id)
//        let sum = BFractionText(fraction: row.wrappedValue.sum)
//            .matchedGeometryEffect(id: "sumID:\(row.id.rawValue)", in: animationNameSpace)
//        VStack {
//            // MARK: - row name-
//            HStack {
//                Menu {
//                    Button("品名を編集", systemImage: "square.and.pencil") {
//                        setAlert(title: "品名を編集", binding: row.name)
//                    }
//                    Button("単位を編集", systemImage: "square.and.pencil") {
//                        setAlert(title: "単位を編集", binding: row.unitName)
//                    }
//                    if row.wrappedValue.option == nil {
//                        Button("割引を追加", systemImage: "circle.badge.plus") {
//                            row.wrappedValue.option = .init(name: "%off", ratio: .init(9, 10))
//                        }
//                    }
//                } label: {
//                    Text(row.wrappedValue.name)
//                        .font(.headline)
//                        .padding(20) // タップ範囲を広げる
//                }
//                .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
//                Spacer()
//
//                if !showDetail {
//                    sum
//                    Text("円")
//                        .font(.caption)
//                }
//
//                Button {
////                    withAnimation {
//                        if showDetail {
//                            showDetails.remove(row.id)
//                        } else {
//                            showDetails.insert(row.id)
//                        }
////                    }
//                } label: {
//                    Image(systemName: "chevron.down.circle")
//                        .rotationEffect(.degrees(showDetail ? 180 : 0))
//                        .padding(.leading, 7)
//                        .padding(.vertical, 5)
//                }
//            }
//            // MARK: - row -
//            if showDetail {
//                Grid {
//                    GridRow(alignment: .lastTextBaseline) {
//                        Text("単価")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .gridColumnAlignment(.listRowSeparatorLeading)
//                        Spacer()
//                        Button {
//                            editFractionState = .init(
//                                id: row.wrappedValue.id.rawValue,
//                                title: "\(tableName) / \(row.wrappedValue.name) / 単価",
//                                fraction: row.wrappedValue.unitPrice
//                            ) { fraction in
//                                row.wrappedValue.unitPrice = fraction
//                                editFractionState = nil
//                            }
//                        } label: {
//                            BFractionText(fraction: row.wrappedValue.unitPrice)
//                                .padding(1)
//                        }
//                        .gridColumnAlignment(.listRowSeparatorTrailing)
//                        Text("円/\(row.wrappedValue.unitName)")
//                            .font(.caption)
//                            .gridColumnAlignment(.listRowSeparatorLeading)
//                    }
//                    GridRow(alignment: .lastTextBaseline) {
//                        Text("数量")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .gridColumnAlignment(.listRowSeparatorLeading)
//                        Spacer()
//                        Button {
//                            editFractionState = .init(
//                                id: row.wrappedValue.id.rawValue,
//                                title: "\(tableName) / \(row.wrappedValue.name) / 数量",
//                                fraction: row.wrappedValue.quantity
//                            ) { fraction in
//                                row.wrappedValue.quantity = fraction
//                                editFractionState = nil
//                            }
//                        } label: {
//                            BFractionText(fraction: row.wrappedValue.quantity)
//                                .padding(1)
//                        }
//                        .gridColumnAlignment(.listRowSeparatorTrailing)
//                        Text(row.wrappedValue.unitName)
//                            .font(.caption)
//                    }
//
//                    if let option = row.wrappedValue.option {
//                        GridRow(alignment: .lastTextBaseline) {
//                            Text("値引き")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                                .gridColumnAlignment(.listRowSeparatorLeading)
//                            Spacer()
//                            Button {
//
//                            } label: {
//                                Text(option.labelText)
//                                    .padding(1)
//                            }
//                            .gridCellColumns(2)
//                        }
//                    }
//                    Divider()
//                        .gridCellUnsizedAxes(.horizontal)
//                    GridRow(alignment: .lastTextBaseline) {
//                        Text("小計")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .gridColumnAlignment(.listRowSeparatorLeading)
//                        Spacer()
//                        sum
//                            .padding(1)
//                        Text("円")
//                            .font(.caption)
//                    }
//                }
//                .padding(.leading, 60)
//            }
//        }
//        .buttonStyle(BorderlessButtonStyle())
//        .padding(.horizontal, 10)
//        .padding(.vertical, 3)
//        .background {
//            RoundedRectangle(cornerRadius: 6)
//                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
//        }
//    }
}

#Preview {
    NavigationStack {
        SumNoteView2<DummyDependency>(.dummy())
    }
}
