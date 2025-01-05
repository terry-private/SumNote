import SwiftUI
import BigIntExtensions
import Entities
import CoreProtocols
import Components
import Combine
import Stores

struct EditAlert<T> {
    var title: String
    var binding: Binding<T>
}

public struct NoteView<Dependency: DependencyProtocol>: View {
    @Environment(\.editMode) private var editMode
    @State var store = Dependency.noteStore
    @State var note: SumNote
    @State var editNameAlert: EditAlert<String>?
    @State var editNameAlertText: String = ""
    @State var addedTableID: SumGroup.ID?
    @State var addedItemID: SumItem.ID?
    @State var editFractionState: EditFractionState?
    @State var showDetails: Set<SumItem.ID> = []
    @Namespace private var animationNameSpace
    public init(note: SumNote) {
        _note = .init(wrappedValue: note)
    }
    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                List {
                    groups()
//                        .listRowBackground(Color(uiColor: .systemFill))
                }
//                .listRowSpacing(-5)
                .listStyle(.plain)
                .onChange(of: addedTableID) {
                    guard let addedTableID else { return }
                    withAnimation {
                        scrollProxy.scrollTo(addedTableID)
                    }
                }
                .onChange(of: addedItemID) {
                    guard let addedItemID else { return }
                    withAnimation {
                        scrollProxy.scrollTo(addedItemID)
                    }
                }
            }
            // MARK: - 総計 -
            HStack {
                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    Text("総計")
                        .foregroundStyle(.secondary)
                    BFractionText(fraction: note.sum, textStyle: .title3)
                    Text("円")
                }
                .padding()
                Spacer()
            }
            .ignoresSafeArea()
        }
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
                        setAlert(title: "表題を編集", binding: $note.name)
                    }
                    Button("グループ編集モード") {
                        withAnimation {
                            editMode?.wrappedValue = .active
                        }
                    }
                    Button("空のグループを追加", systemImage: "note.text.badge.plus") {
                        withAnimation {
                            let newTable = SumGroup(name: "グループ\(note.groups.count+1)", items: [.init(name: "アイテム", unitPrice: 0, quantity: 0, unitName: "個")])
                            note.groups.append(newTable)
                            addedTableID = newTable.id
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
        .onChange(of: note) {
            Task { @MainActor in
                try await store.update(note)
            }
        }
    }
}

// MARK: - set alert -
extension NoteView {
    func setAlert(title: String, binding: Binding<String>) {
        editNameAlert = nil
        Task { @MainActor in
            editNameAlertText = binding.wrappedValue
            editNameAlert = .init(title: title, binding: binding)
        }
    }
}

// MARK: - ViewBuilders -
extension NoteView {
    @ViewBuilder
    func groups() -> some View {
        ForEach($note.groups) { $table in
            if editMode?.wrappedValue.isEditing == true {
                VStack {
                    HStack {
                        Text(table.name)
                            .font(.headline)
                        Spacer()
                    }
//                    footer(table: $table)
                }
                .listRowSeparator(.hidden)
            } else {
                Section(header: header(table: $table)) {
                    ForEach($table.items) { $row in
                        tableRow(tableName: table.name, $row)
                    }
                    .onMove { indexSet, index in
                        table.items.move(fromOffsets: indexSet, toOffset: index)
                    }
                    .onDelete { indexSet in
                        table.items.remove(atOffsets: indexSet)
                    }
                }
                .listRowSeparator(.hidden)
            }
        }
        .onMove { indexSet, index in
            note.groups.move(fromOffsets: indexSet, toOffset: index)
        }
        .onDelete { indexSet in
            note.groups.remove(atOffsets: indexSet)
        }
    }
    
    // MARK: - header footer -
    @ViewBuilder
    func header(table: Binding<SumGroup>) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Menu {
                Button("空のアイテムを追加", systemImage: "square.badge.plus") {
                    withAnimation {
                        let item: SumItem = .init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個")
                        table.wrappedValue.items.append(item)
                        addedItemID = item.id
                    }
                }
                Button("テンプレートから追加", systemImage: "macwindow.badge.plus") {

                }
            } label: {
                Image(systemName: "plus")
                    .padding(15) // タップ範囲を広げる
            }
            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
            .padding(.trailing, 20)

            Menu {
                Button("グループ名を編集", systemImage: "square.and.pencil") {
                    setAlert(title: "表題を編集", binding: table.name)
                }
                Button("テキストコピー", systemImage: "pencil") {
                    UIPasteboard.general.string = table.wrappedValue.description()
                }
            } label: {
                Text(table.wrappedValue.name)
                    .font(.title3)
                    .padding(20) // タップ範囲を広げる
            }
            .padding(-16) // タップ範囲を広げてもレイアウトサイズはそのままにする
            Spacer()
            Text("合計")
                .font(.caption)
            BFractionText(fraction: table.wrappedValue.sum, textStyle: .title3, rounded: 2)
                .foregroundStyle(Color(uiColor: .label))
                .bold()
            Text("円")
                .font(.caption)
        }
        .listRowSeparator(.hidden)
    }
    func footer(table: Binding<SumGroup>) -> some View {
        HStack {
            Spacer()
            Menu {
                Button("空のアイテムを追加", systemImage: "square.badge.plus") {
                    withAnimation {
                        table.wrappedValue.items.append(.init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個"))
                    }
                }
                Button("テンプレートから追加", systemImage: "macwindow.badge.plus") {

                }
            } label: {
                Image(systemName: "plus")
                    .padding(15) // タップ範囲を広げる
            }
            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
            Spacer()
        }
    }
    
    // MARK: - table row -
    @ViewBuilder
    func tableRow(tableName: String, _ row: Binding<SumItem>) -> some View {
        let showDetail: Bool = showDetails.contains(row.wrappedValue.id)
        let sum = BFractionText(fraction: row.wrappedValue.sum)
            .matchedGeometryEffect(id: "sumID:\(row.id.rawValue)", in: animationNameSpace)
        VStack {
            // MARK: - row name-
            HStack {
                Menu {
                    Button("品名を編集", systemImage: "square.and.pencil") {
                        setAlert(title: "品名を編集", binding: row.name)
                    }
                    Button("単位を編集", systemImage: "square.and.pencil") {
                        setAlert(title: "単位を編集", binding: row.unitName)
                    }
                    if row.wrappedValue.option == nil {
                        Button("割引を追加", systemImage: "circle.badge.plus") {
                            row.wrappedValue.option = .init(style: .percentile, 10)
                        }
                    }
                } label: {
                    Text(row.wrappedValue.name)
                        .font(.headline)
                        .padding(20) // タップ範囲を広げる
                }
                .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
                Spacer()

                if !showDetail {
                    sum
                    Text("円")
                        .font(.caption)
                }

                Button {
//                    withAnimation {
                        if showDetail {
                            showDetails.remove(row.id)
                        } else {
                            showDetails.insert(row.id)
                        }
//                    }
                } label: {
                    Image(systemName: "chevron.down.circle")
                        .rotationEffect(.degrees(showDetail ? 180 : 0))
                        .padding(.leading, 7)
                        .padding(.vertical, 5)
                }
            }
            // MARK: - row -
            if showDetail {
                Grid {
                    GridRow(alignment: .lastTextBaseline) {
                        Text("単価")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.listRowSeparatorLeading)
                        Spacer()
                        Button {
                            editFractionState = .init(
                                id: row.wrappedValue.id.rawValue,
                                title: "\(tableName) / \(row.wrappedValue.name) / 単価",
                                fraction: row.wrappedValue.unitPrice
                            ) { fraction in
                                row.wrappedValue.unitPrice = fraction
                                editFractionState = nil
                            }
                        } label: {
                            BFractionText(fraction: row.wrappedValue.unitPrice)
                                .padding(1)
                        }
                        .gridColumnAlignment(.listRowSeparatorTrailing)
                        Text("円/\(row.wrappedValue.unitName)")
                            .font(.caption)
                            .gridColumnAlignment(.listRowSeparatorLeading)
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        Text("数量")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.listRowSeparatorLeading)
                        Spacer()
                        Button {
                            editFractionState = .init(
                                id: row.wrappedValue.id.rawValue,
                                title: "\(tableName) / \(row.wrappedValue.name) / 数量",
                                fraction: row.wrappedValue.quantity
                            ) { fraction in
                                row.wrappedValue.quantity = fraction
                                editFractionState = nil
                            }
                        } label: {
                            BFractionText(fraction: row.wrappedValue.quantity)
                                .padding(1)
                        }
                        .gridColumnAlignment(.listRowSeparatorTrailing)
                        Text(row.wrappedValue.unitName)
                            .font(.caption)
                    }

                    if let option = row.wrappedValue.option {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("値引き")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.listRowSeparatorLeading)
                            Spacer()
                            Button {

                            } label: {
                                Text(option.labelText)
                                    .padding(1)
                            }
                            .gridCellColumns(2)
                        }
                    }
                    Divider()
                        .gridCellUnsizedAxes(.horizontal)
                    GridRow(alignment: .lastTextBaseline) {
                        Text("小計")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.listRowSeparatorLeading)
                        Spacer()
                        sum
                            .padding(1)
                        Text("円")
                            .font(.caption)
                    }
                }
                .padding(.leading, 60)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
        }
    }
}

#Preview {
    NavigationStack {
        NoteView<DummyDependency>(note: .dummy(5))
    }
}
