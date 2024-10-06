import SwiftUI
import BigInt
import Entities
import CoreProtocols
import Components
import Combine
import Stores

struct EditAlert<T> {
    var title: String
    var binding: Binding<T>
}
struct EditFractionState: Identifiable {
    var id: String
    var title: String
    var fraction: BFraction
    var completion: (BFraction) -> Void
}

public struct NoteView<Dependency: DependencyProtocol>: View {
    @Environment(\.editMode) private var editMode
    @State var store = Dependency.noteStore
    @State var note: CalcNote
    @State var editNameAlert: EditAlert<String>?
    @State var editNameAlertText: String = ""
    @State var addedTableID: CalcTable.ID?
    @State var editFractionState: EditFractionState?
    public init(note: CalcNote) {
        _note = .init(wrappedValue: note)
    }
    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                List {
                    tables()
                }
                .listStyle(.insetGrouped)
                .onChange(of: addedTableID) {
                    guard let addedTableID else { return }
                    withAnimation {
                        scrollProxy.scrollTo(addedTableID)
                    }
                }
            }
            // MARK: - 総計 -
            HStack {
                Spacer()
                HStack {
                    Text("総計:")
                    BFractionText(fraction: note.sum)
                    Text("円")
                }
                .padding()
                Spacer()
            }
            .ignoresSafeArea()
            .background(.ultraThinMaterial)
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
                    Button("表編集") {
                        withAnimation {
                            editMode?.wrappedValue = .active
                        }
                    }
                    Button("ノート名を編集", systemImage: "square.and.pencil") {
                        setAlert(title: "表題を編集", binding: $note.name)
                    }
                    Button("空の表を追加", systemImage: "note.text.badge.plus") {
                        withAnimation {
                            let newTable = CalcTable(name: "表", rows: [.init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個")])
                            note.tables.append(newTable)
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
    func tables() -> some View {
        ForEach($note.tables) { $table in
            if editMode?.wrappedValue.isEditing == true {
                VStack {
                    HStack {
                        Text(table.name)
                            .font(.headline)
                        Spacer()
                    }
                    footer(table: $table)
                }
            } else {
                Section(header: header(table: $table), footer: footer(table: $table)) {
                    ForEach($table.rows) { $row in
                        tableRow(tableName: table.name, $row)
                    }
                    .onMove { indexSet, index in
                        table.rows.move(fromOffsets: indexSet, toOffset: index)
                    }
                    .onDelete { indexSet in
                        table.rows.remove(atOffsets: indexSet)
                    }
                }
            }
        }
        .onMove { indexSet, index in
            note.tables.move(fromOffsets: indexSet, toOffset: index)
        }
        .onDelete { indexSet in
            note.tables.remove(atOffsets: indexSet)
        }
    }
    
    // MARK: - header footer -
    @ViewBuilder
    func header(table: Binding<CalcTable>) -> some View {
        HStack {
            Menu {
                Button("表題を編集", systemImage: "square.and.pencil") {
                    setAlert(title: "表題を編集", binding: table.name)
                }
                Button("テキストコピー", systemImage: "pencil") {
                    UIPasteboard.general.string = table.wrappedValue.description()
                }
            } label: {
                Text(table.wrappedValue.name)
                    .font(.headline)
                    .padding(20) // タップ範囲を広げる
            }
            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
            Spacer()
            Menu {
                Button("空の行を追加", systemImage: "square.badge.plus") {
                    withAnimation {
                        table.wrappedValue.rows.append(.init(name: "品名", unitPrice: .ZERO, quantity: .ONE, unitName: "個"))
                    }
                }
                Button("テンプレートから追加", systemImage: "macwindow.badge.plus") {
                    
                }
            } label: {
                Image(systemName: "plus")
                    .padding(20) // タップ範囲を広げる
            }
            .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
        }
    }
    func footer(table: Binding<CalcTable>) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Spacer()
            Text("合計")
            BFractionText(fraction: table.wrappedValue.sum, textStyle: .body, rounded: 2)
                .bold()
            Text("円")
                .font(.caption)
        }
        .foregroundStyle(Color.primary)
    }
    
    // MARK: - table row -
    @ViewBuilder
    func tableRow(tableName: String, _ row: Binding<CalcRow>) -> some View {
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
                    Button("オプションを追加", systemImage: "circle.badge.plus") {
                        row.wrappedValue.options.append(.init(name: "10% OFF", ratio: .init(9, 10)))
                    }
                } label: {
                    Text(row.wrappedValue.name)
                        .font(.headline)
                        .padding(20) // タップ範囲を広げる
                }
                .padding(-20) // タップ範囲を広げてもレイアウトサイズはそのままにする
                Spacer()
            }
            // MARK: - row -
            HStack(alignment: .lastTextBaseline, spacing: 0) {
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
                }
                
                Text("円/\(row.wrappedValue.unitName)")
                    .font(.caption)
                
                Spacer()
                
                Text(String("x"))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                
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
                }
                
                Text(row.wrappedValue.unitName)
                    .font(.caption)
                
                Spacer()
                
                Text("=")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)

                Spacer()
                
                BFractionText(fraction: row.wrappedValue.subtotal)

                Text("円")
                    .font(.caption)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical, 3)

            ForEach(row.options) { option in
                HStack {
                    Spacer()
                    Text(String("x"))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    Menu {
                        Button("オプション名を編集", systemImage: "square.and.pencil") {
                            setAlert(title: "オプション名を編集", binding: option.name)
                        }
                        Button("割合を編集", systemImage: "square.and.pencil") {
                            editFractionState = .init(
                                id: option.wrappedValue.id.rawValue,
                                title: "\(tableName) / \(row.wrappedValue.name) / \(option.wrappedValue.name)",
                                fraction: option.wrappedValue.ratio
                            ) { fraction in
                                option.wrappedValue.ratio = fraction
                                editFractionState = nil
                            }
                        }
                        Button("オプションを削除", role: .destructive) {
                            guard let index = row.wrappedValue.options.firstIndex(of: option.wrappedValue) else { return }
                            row.wrappedValue.options.remove(at: index)
                        }

                    } label: {
                        HStack {
                            BFractionText(fraction: option.wrappedValue.ratio)

                            Text("(\(option.wrappedValue.name))")
                                .font(.caption)
                        }
                    }
                }
            }
            if !row.options.isEmpty {
                HStack {
                    Spacer()

                    Text(String("="))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    BFractionText(fraction: row.wrappedValue.sum)
                    Text("円")
                        .font(.caption)
                }
                .padding(.top, 3)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteView<DummyDependency>(note: .dummy(5))
    }
}
