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

public struct SumNoteView2<Dependency: DependencyProtocol>: View {
    @Environment(\.editMode) private var editMode
    @State var store = Dependency.noteStore
    @State var note: SumNote2
//    @State var group: SumGroup2
    @State var editNameAlert: EditAlert<String>?
    @State var editNameAlertText: String = ""
    @State var editFractionState: EditFractionState?
    @State var showDetails: Set<SumItem2.ID> = []
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
        .alert(editNameAlert?.title ?? "", isPresented: Binding(get: { editNameAlert != nil}, set: { if !$0 { editNameAlert = nil }})) {
            if let editNameAlert {
                TextField("テキストフィールド", text: $editNameAlertText)
                Button("Cancel", action: {})
                Button("OK") {
                    guard !editNameAlertText.isBlank() else { return }
                    editNameAlert.binding.wrappedValue = editNameAlertText
                }
            }
        }
        .sheet(item: $editFractionState) { state in
            CalculatorInputView(
                title: state.title,
                value: state.fraction,
                completion: state.completion
            ) {
                editFractionState = nil
            }
            .presentationDetents([.height(CalculatorLayoutLogics.displaySize(maxSize: UIScreen.main.bounds.size).height)]
            )
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
                        Text(row.name)
                            .font(.headline)
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Spacer()
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

                    } label: {
                        HStack {
                            VStack {
                                HStack {
                                    Text(group.name)
                                        .font(.headline)
                                    Spacer()
                                }
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Spacer()
                                    BFractionText(fraction: group.sum())
                                    Text("円")
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                case .item(let item):
                    VStack {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(item.name)
                            Spacer()
                            BFractionText(fraction: item.sum)
                            Text("円")
                                .font(.caption)
                        }
                        HStack(alignment: .lastTextBaseline) {
                            SumItemValueButton(title: "単価") {

                            } content: {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    BFractionText(fraction: item.unitPrice)
                                    Text("円/\(item.unitName)")
                                        .font(.caption)
                                }
                            }
                            .foregroundStyle(.indigo)
                            SumItemValueButton(title: "数量") {

                            } content:  {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    BFractionText(fraction: item.quantity)
                                    Text(item.unitName)
                                        .font(.caption)
                                }
                            }
                            .foregroundStyle(.blue)
                            if let option = item.option {
                                SumItemValueButton(title: "値引き") {

                                } content: {
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        BFractionText(fraction: option.numerator)
                                        Text(option.prefix)
                                            .font(.caption)
                                    }
                                }
                                .foregroundStyle(.red)
                            } else {
                            }
                            Spacer()
                        }
                        .padding(5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                    .listRowSeparator(.hidden)
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
