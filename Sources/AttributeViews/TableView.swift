//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

public struct TableView<Config: AttributeViewConfig>: View {
    
    //@Binding var value: [[LineAttribute]]
    let label: String
    
    @StateObject var viewModel: TableViewModel<Config>
    
//    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { root.wrappedValue.modify(attribute: path, value: $0) }
            ),
            viewModel: TableViewModel(root: root, path: path, columns: columns),
            label: label
        )
    }
    
    public init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String] = { _ in [] }, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            value: value,
            viewModel: TableViewModel(value: value, errors: errors, subErrors: subErrors, columns: columns),
            label: label
        )
    }
    
    private init(value: Binding<[[LineAttribute]]>, viewModel: TableViewModel<Config>, label: String) {
        //self._value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.pretty.capitalized)
                .font(.headline)
//                .foregroundColor(config.textColor)
            ForEach(viewModel.listErrors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
                List(selection: $viewModel.selection) {
                    VStack {
                        HStack {
                            ForEach(viewModel.columns, id: \.name) { column in
                                Text(column.name.pretty)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            Spacer().frame(width: 20)
                        }
                    }
                    ForEach(viewModel.rows.indices, id: \.self) { index in
                        TableRowView<Config>(
                            viewModel: viewModel.rows[index],
                            onDelete: { viewModel.deleteRow(self, row: index) }
                        )
                    }.onMove {
                        viewModel.moveElements(self, atOffsets: $0, to: $1)
                    }.onDelete {
                        viewModel.deleteElements(self, atOffsets: $0)
                    }
                }.frame(minHeight: CGFloat(28 * viewModel.rows.count) + 75)
                .onExitCommand {
                    viewModel.selection.removeAll(keepingCapacity: true)
                }
                VStack {
                    HStack {
                        ForEach(viewModel.newRow.indices, id: \.self) { index in
                            VStack {
                                LineAttributeView<Config>(
                                    attribute: $viewModel.newRow[index],
                                    errors: Binding(get: { viewModel.errors(self, forRow: viewModel.value.count)[index] }, set: {_ in }),
                                    label: ""
                                )
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                        VStack {
                            Button(action: { viewModel.addElement(self) }, label: {
                                Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                            }).buttonStyle(PlainButtonStyle())
                              .foregroundColor(.blue)
                        }.frame(width: 20)
                    }
                }.padding(.leading, 15).padding(.trailing, 18).padding(.bottom, 15)
            }
        }
    }

}

struct TableView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "table",
                        type: .table(columns: [("b", .bool), ("i", .integer), ("f", .float)])
                    )
                ],
                attributes: [
                    "table": .table([
                        [.bool(false), .integer(1), .float(1.1)],
                        [.bool(true), .integer(2), .float(2.2)]
                    ], columns: [("b", .bool), ("i", .integer), ("f", .float)]
                    )
                ],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["table"].wrappedValue.tableValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                columns: [.init(name: "b", type: .bool), .init(name: "i", type: .integer), .init(name: "f", type: .float)]
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [[LineAttribute]] = []
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig>(
                value: $value,
                label: "Binding",
                columns: [
                    .init(name: "Bool", type: .bool),
                    .init(name: "Integer", type: .integer),
                    .init(name: "Float", type: .float),
                    .init(name: "Expression", type: .expression(language: .swift)),
                    .init(name: "Enumerated", type: .enumerated(validValues: ["Initial", "Suspend"])),
                    .init(name: "Line", type: .line)
                ]
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}

protocol TableViewDataSource {
    
    func addElement(_ row: [LineAttribute])
    func deleteElements(atOffsets offsets: IndexSet)
    func moveElements(atOffsets source: IndexSet, to destination: Int)
    func view(forElementAtRow row: Int, column: Int) -> AnyView
    
}

struct KeyPathTableViewDataSource<Root: Modifiable, Config: AttributeViewConfig>: TableViewDataSource {
    
    let root: Binding<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>
    
    func addElement(_ row: [LineAttribute]) {
        _ = root.wrappedValue.addItem(row, to: path)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        _ = root.wrappedValue.deleteItems(table: path, items: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        _ = root.wrappedValue.moveItems(table: path, from: source, to: destination)
    }
    
    func view(forElementAtRow row: Int, column: Int) -> AnyView {
        AnyView(LineAttributeView<Config>(root: root, path: path[row][column], label: ""))
    }
    
}

struct BindingTableViewDataSource<Config: AttributeViewConfig>: TableViewDataSource {
    
    let value: Binding<[[LineAttribute]]>
    
    func addElement(_ row: [LineAttribute]) {
        value.wrappedValue.append(row)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        value.wrappedValue.remove(atOffsets: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        value.wrappedValue.move(fromOffsets: source, toOffset: destination)
    }
    
    func view(forElementAtRow row: Int, column: Int) -> AnyView {
        AnyView(LineAttributeView<Config>(
            attribute: Binding(
                get: {
                    row < value.wrappedValue.count && column < value.wrappedValue[row].count ? value.wrappedValue[row][column] : .bool(false)
                },
                set: {
                    guard row < value.wrappedValue.count && column < value.wrappedValue[row].count else {
                        return
                    }
                    value.wrappedValue[row][column] = $0
                }
            ),
            label: ""
        ))
    }
    
}

final class TableViewModel<Config: AttributeViewConfig>: ObservableObject {
    
    private let valueBinding: Binding<[[LineAttribute]]>
    let errors: Binding<[String]>
    let subErrors: (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String]
    let columns: [BlockAttributeType.TableColumn]
    let emptyRow: [LineAttribute]
    
    @Published var newRow: [LineAttribute]
    @Published var selection: Set<Int> = []
    
    @Published var rows: [TableRowViewModel] = []
    
    let dataSource: TableViewDataSource
    
    var value: [[LineAttribute]] {
        get {
            valueBinding.wrappedValue
        } set {
            valueBinding.wrappedValue = newValue
            objectWillChange.send()
        }
    }
    
    var listErrors: [String] {
        errors.wrappedValue
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn]) {
        self.valueBinding = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: { _ = root.wrappedValue.modify(attribute: path, value: $0) }
        )
        self.errors = Binding(
            get: { root.wrappedValue.errorBag.errors(forPath: path).map(\.message) },
            set: { _ in }
        )
        self.subErrors = {
            root.wrappedValue.errorBag.errors(forPath: ReadOnlyPath(keyPath: path.keyPath.appending(path: $0.keyPath), ancestors: [])).map(\.message)
        }
        self.columns = columns
        self.emptyRow = columns.map(\.type.defaultValue)
        self.dataSource = KeyPathTableViewDataSource<Root, Config>(root: root, path: path)
        self.newRow = emptyRow
        syncRows()
    }
    
    init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]>, subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String], columns: [BlockAttributeType.TableColumn]) {
        self.valueBinding = value
        self.errors = errors
        self.subErrors = subErrors
        self.columns = columns
        self.emptyRow = columns.map(\.type.defaultValue)
        self.dataSource = BindingTableViewDataSource<Config>(value: value)
        self.newRow = emptyRow
        syncRows()
    }
    
    func errors(_ view: TableView<Config>, forRow _: Int) -> [[String]] {
        columns.map { _ in [] }
    }
    
    func addElement(_ view: TableView<Config>) {
        dataSource.addElement(newRow)
        syncRows()
        newRow = emptyRow
        objectWillChange.send()
    }
    
    func deleteRow(_ view: TableView<Config>, row: Int) {
        guard row < value.count else {
            return
        }
        let offsets: IndexSet = selection.contains(row)
            ? IndexSet(selection)
            : [row]
        dataSource.deleteElements(atOffsets: offsets)
        syncRows()
        objectWillChange.send()
    }
    
    func deleteElements(_ view: TableView<Config>, atOffsets offsets: IndexSet) {
        if offsets.isEmpty {
            return
        }
        dataSource.deleteElements(atOffsets: offsets)
        syncRows()
        notifyChildren(IndexSet(offsets.reduce(rows.count) { min($0, $1) }..<rows.count))
        objectWillChange.send()
    }
    
    func moveElements(_ view: TableView<Config>, atOffsets source: IndexSet, to destination: Int) {
        selection.removeAll()
        dataSource.moveElements(atOffsets: source, to: destination)
        syncRows()
        notifyChildren(IndexSet(source.reduce(destination) { min($0, $1) }..<rows.count))
        objectWillChange.send()
    }
    
    private func notifyChildren(_ indexes: IndexSet) {
        for index in indexes {
            rows[index].objectWillChange.send()
        }
    }
    
    private func syncRows() {
        if rows.count > value.count {
            rows.removeLast(rows.count - value.count)
            return
        }
        if rows.count < value.count {
            rows.append(contentsOf: (rows.count..<value.count).map { row in
                TableRowViewModel(
                    table: valueBinding,
                    rowIndex: row,
                    errors: .constant([]),
                    lineAttributeView: {
                        self.dataSource.view(forElementAtRow: $0, column: $1)
                    }
                )
            })
        }
    }
    
}
