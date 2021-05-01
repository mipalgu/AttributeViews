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
    
    var selectedRows: State<Set<Int>> {
        get {
            _selection
        } set {
            _selection = newValue
        }
    }
    
    let label: String
    
    @State var newRow: [LineAttribute]
    @State var selection: Set<Int> = []
    
    @StateObject var viewModel: TableViewModel<Config>
    
//    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            viewModel: TableViewModel(root: root, path: path, columns: columns),
            label: label
        )
    }
    
    public init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String] = { _ in [] }, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            viewModel: TableViewModel(value: value, errors: errors, subErrors: subErrors, columns: columns),
            label: label
        )
    }
    
    private init(viewModel: TableViewModel<Config>, label: String) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self._newRow = State(initialValue: viewModel.newRow)
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
                VStack {
                    List(selection: $selection) {
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
                        ForEach(viewModel.value.indices, id: \.self) { index in
                            TableRowView<Config>(
                                row: viewModel.row(atIndex: index),
                                onDelete: { viewModel.deleteRow(self, row: index) }
                            )
                        }.onMove {
                            viewModel.moveElements(self, atOffsets: $0, to: $1)
                        }.onDelete {
                            viewModel.deleteElements(self, atOffsets: $0)
                        }
                    }.frame(minHeight: CGFloat(28 * viewModel.value.count) + 75)
                    .onExitCommand {
                        selection.removeAll(keepingCapacity: true)
                    }
                }
                VStack {
                    HStack {
                        ForEach(newRow.indices, id: \.self) { index in
                            VStack {
                                LineAttributeView<Config>(
                                    attribute: $newRow[index],
                                    errors: Binding(get: { viewModel.errors(self, forRow: viewModel.value.count)[index] }, set: {_ in }),
                                    label: ""
                                )
                                ForEach(viewModel.errors(self, forRow: viewModel.value.count)[index], id: \.self) { error in
                                    Text(error).foregroundColor(.red)
                                }
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
    
    var newRow: [LineAttribute] { get }
    
    func addElement()
    func deleteElements(atOffsets offsets: IndexSet)
    func moveElements(atOffsets source: IndexSet, to destination: Int)
    
}

struct KeyPathTableViewDataSource<Root: Modifiable>: TableViewDataSource {
    
    let root: Binding<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>
    let columns: [BlockAttributeType.TableColumn]
    
    var newRow: [LineAttribute] {
        columns.map(\.type.defaultValue)
    }
    
    func addElement() {
        _ = root.wrappedValue.addItem(newRow, to: path)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        _ = root.wrappedValue.deleteItems(table: path, items: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        _ = root.wrappedValue.moveItems(table: path, from: source, to: destination)
    }
    
}

struct BindingTableViewDataSource: TableViewDataSource {
    
    let value: Binding<[[LineAttribute]]>
    let columns: [BlockAttributeType.TableColumn]
    
    var newRow: [LineAttribute] {
        columns.map(\.type.defaultValue)
    }
    
    func addElement() {
        value.wrappedValue.append(newRow)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        value.wrappedValue.remove(atOffsets: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        value.wrappedValue.move(fromOffsets: source, toOffset: destination)
    }
    
}

final class TableViewModel<Config: AttributeViewConfig>: ObservableObject {
    
    private let valueBinding: Binding<[[LineAttribute]]>
    let errors: Binding<[String]>
    let subErrors: (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String]
    let columns: [BlockAttributeType.TableColumn]
    
    private var rows: [[LineAttributeViewModel]] = []
    
    var dataSource: TableViewDataSource
    
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
    
    var newRow: [LineAttribute] {
        dataSource.newRow
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
        self.dataSource = KeyPathTableViewDataSource(root: root, path: path, columns: columns)
    }
    
    init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]>, subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String], columns: [BlockAttributeType.TableColumn]) {
        self.valueBinding = value
        self.errors = errors
        self.subErrors = subErrors
        self.columns = columns
        self.dataSource = BindingTableViewDataSource(value: value, columns: columns)
    }
    
    func errors(_ view: TableView<Config>, forRow _: Int) -> [[String]] {
        columns.map { _ in [] }
    }
    
    func addElement(_ view: TableView<Config>) {
        dataSource.addElement()
        objectWillChange.send()
    }
    
    func deleteRow(_ view: TableView<Config>, row: Int) {
        guard row < value.count else {
            return
        }
        let offsets: IndexSet = view.selection.contains(row)
            ? IndexSet(view.selection)
            : [row]
        dataSource.deleteElements(atOffsets: offsets)
        objectWillChange.send()
    }
    
    func deleteElements(_ view: TableView<Config>, atOffsets offsets: IndexSet) {
        dataSource.deleteElements(atOffsets: offsets)
        objectWillChange.send()
    }
    
    func moveElements(_ view: TableView<Config>, atOffsets source: IndexSet, to destination: Int) {
        view.selection.removeAll()
        dataSource.moveElements(atOffsets: source, to: destination)
        objectWillChange.send()
    }
    
    func row(atIndex index: Int) -> [LineAttributeViewModel] {
        if rows.count <= index {
            rows.append(
                contentsOf: (rows.count...index).map { row in
                    columns.indices.map { column in
                        LineAttributeViewModel(
                            value: Binding(
                                get: {
                                    guard row < self.value.count && column < self.value[row].count else {
                                        return .bool(false)
                                    }
                                    return self.value[row][column]
                                },
                                set: {
                                    guard row < self.value.count && column < self.value[row].count else {
                                        return
                                    }
                                    self.value[row][column] = $0
                                }
                            )
                        )
                    }
                }
            )
        }
        return rows[index]
    }
    
}
