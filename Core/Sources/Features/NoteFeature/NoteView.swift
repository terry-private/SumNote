import SwiftUI
import BigInt
import Entities
import CoreProtocols
import Components
import Combine

struct EditAlert<T> {
    var title: String
    var binding: Binding<T>
}

public struct NoteView<Dependency: DependencyProtocol>: View {
    @Environment(\.editMode) private var editMode
    @State var store = Dependency.noteStore
    @State var note: CalcNote
    @State var editNameAlert: EditAlert<String>?
    @State var editFractionAlert: EditAlert<BFraction>?
    @State var editNameAlertText: String = ""
    @State var addedTableID: CalcTable.ID?
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
        .alert(editFractionAlert?.title ?? "", isPresented: Binding(get: { editFractionAlert != nil}, set: { if !$0 { editFractionAlert = nil }})) {
            if let editFractionAlert {
                TextField("テキストフィールド", text: $editNameAlertText)
                    .onReceive(Just(editNameAlertText)) { _ in
                        let cnt = editNameAlertText.split(separator: ".").first?.count ?? 0
                        editNameAlertText = editNameAlertText.prefix(18 + cnt).description
                    }
                    .keyboardType(.decimalPad)
                Button("Cancel") {}
                Button("OK") {
                    if let newValue = BFraction(editNameAlertText) {
                        editFractionAlert.binding.wrappedValue = newValue
                    }
                }
            }
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
                } label: {
                    Label("menu", systemImage: "line.3.horizontal.circle")
                }
            }
        }
        // MARK: - navigationTitle -
        .navigationTitle(note.name)
        // MARK: - onChange -
        .onChange(of: note) {
            store.update(note)
        }
    }
}

// MARK: - set alert -
extension NoteView {
    func setAlert(title: String, binding: Binding<String>) {
        editNameAlert = nil
        editFractionAlert = nil
        Task { @MainActor in
            editNameAlertText = binding.wrappedValue
            editNameAlert = .init(title: title, binding: binding)
        }
    }
    func setAlert(title: String, binding: Binding<BFraction>) {
        editNameAlert = nil
        editFractionAlert = nil
        Task { @MainActor in
            editNameAlertText = binding.wrappedValue.decimalString(rounded: 18)
            editFractionAlert = .init(title: title, binding: binding)
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
                        tableRow($row)
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
                    UIPasteboard.general.string = table.wrappedValue.description
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
    func tableRow(_ row: Binding<CalcRow>) -> some View {
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
                    setAlert(title: "単価を編集", binding: row.unitPrice)
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
                    setAlert(title: "数量を編集", binding: row.quantity)
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
                
                BFractionText(fraction: row.wrappedValue.sum)
                
                Text("円")
                    .font(.caption)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.vertical, 3)
        }
//        Menu {
//            Button("品名を編集", systemImage: "square.and.pencil") {
//                setAlert(title: "品名を編集", binding: row.name)
//            }
//            Button("単位を編集", systemImage: "square.and.pencil") {
//                setAlert(title: "単位を編集", binding: row.unitName)
//            }
//            Button("単価を編集") {
//                setAlert(title: "単価を編集", binding: row.unitPrice)
//            }
//            Button("数量を編集") {
//                setAlert(title: "数量を編集", binding: row.quantity)
//            }
//        } label: {
//            VStack {
//                // MARK: - row name-
//                HStack {
//                    Text(row.wrappedValue.name)
//                        .font(.headline)
//                    Spacer()
//                }
//                // MARK: - row -
//                HStack(alignment: .lastTextBaseline, spacing: 0) {
//                    BFractionText(fraction: row.wrappedValue.unitPrice)
//                    
//                    Text("円/\(row.wrappedValue.unitName)")
//                        .font(.caption)
//                    
//                    Spacer()
//                    
//                    Text(String("x"))
//                        .font(.caption)
//                        .foregroundStyle(Color.secondary)
//                    
//                    Spacer()
//                    
//                    BFractionText(fraction: row.wrappedValue.quantity)
//                    
//                    Text(row.wrappedValue.unitName)
//                        .font(.caption)
//                    
//                    Spacer()
//                    
//                    Text("=")
//                        .font(.caption)
//                        .foregroundStyle(Color.secondary)
//                    
//                    Spacer()
//                    
//                    BFractionText(fraction: row.wrappedValue.sum)
//                    
//                    Text("円")
//                        .font(.caption)
//                }
//                .buttonStyle(BorderlessButtonStyle())
//                .padding(.vertical, 3)
//            }
//            .foregroundStyle(Color.primary)
//        }
    }
}

#Preview {
    NavigationStack {
        NoteView<DummyDependency>(note: .dummy(5))
    }
}
