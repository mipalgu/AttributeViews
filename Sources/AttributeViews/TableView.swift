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

public struct TableView<Config: AttributeViewConfig>: View, SelectableListViewProtocol {
    
    @Binding var value: [Row<[LineAttribute]>]
    @Binding var errors: [String]
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @State var newRow: [LineAttribute]
    @State var selection: Set<Row<[LineAttribute]>>
    
    private let viewModel: AnyListViewModel<Self, [LineAttribute], TableRowView<Config>, [String]>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        var idCache = IDCache<[LineAttribute]>()
        self._value = Binding(
            get: {
                root.wrappedValue[keyPath: path.keyPath].enumerated().map { (index, row) in
                    Row(id: idCache.id(for: row), index: index, data: row)
                }
            },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0.map(\.data))
            }
        )
        self._errors = Binding(
            get: { root.wrappedValue.errorBag.errors(forPath: path).map(\.message) },
            set: { _ in }
        )
        self._selection = State(initialValue: [])
        self.label = label
        self.columns = columns
        self._newRow = State<[LineAttribute]>(initialValue: columns.map { $0.type.defaultValue })
        self.viewModel = AnyListViewModel(TableViewKeyPathViewModel<Config, Root>(root: root, path: path))
    }
    
    public init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]> = .constant([]), label: String, columns: [BlockAttributeType.TableColumn]) {
        var idCache = IDCache<[LineAttribute]>()
        self._errors = errors
        self._selection = State(initialValue: [])
        self._value = Binding(
            get: {
                value.wrappedValue.enumerated().map { (index, row) in
                    Row(id: idCache.id(for: row), index: index, data: row)
                }
            },
            set: {
                value.wrappedValue = $0.map(\.data)
            }
        )
        self.label = label
        self.columns = columns
        self._newRow = State<[LineAttribute]>(initialValue: columns.map(\.type.defaultValue))
        self.viewModel = AnyListViewModel(TableViewBindingViewModel<Config>(value: value))
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.pretty.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
                VStack {
                    List(selection: $selection) {
                        VStack {
                            HStack {
                                ForEach(columns, id: \.name) { column in
                                    Text(column.name.pretty)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                Spacer().frame(width: 20)
                            }
                        }
                        ForEach(value, id: \.self) { row in
                            viewModel.rowView(self, forRow: row.index)
                        }.onMove {
                            viewModel.moveElements(self, atOffsets: $0, to: $1)
                        }.onDelete {
                            viewModel.deleteElements(self, atOffsets: $0)
                        }
                    }.frame(minHeight: CGFloat(28 * value.count) + 75)
                    .onExitCommand { selection = [] }
                }
                VStack {
                    HStack {
                        ForEach(newRow.indices, id: \.self) { index in
                            VStack {
                                LineAttributeView<Config>(
                                    attribute: $newRow[index],
                                    errors: Binding(get: { viewModel.errors(self, forRow: value.count)[index] }, set: {_ in }),
                                    label: ""
                                )
                                ForEach(viewModel.errors(self, forRow: value.count)[index], id: \.self) { error in
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



fileprivate struct TableViewKeyPathViewModel<Config: AttributeViewConfig, Root: Modifiable>: ListViewModelProtocol {
    
    let root: Binding<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>
    
    var listErrors: [String] {
        root.wrappedValue.errorBag.errors(includingDescendantsForPath: path).map(\.message)
    }
    
    var latestValue: [[LineAttribute]] {
        root.wrappedValue[keyPath: path.keyPath]
    }
    
    init(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>) {
        self.root = root
        self.path = path
    }
    
    func addElement(_ view: TableView<Config>) {
        try? root.wrappedValue.addItem(view.newRow, to: path)
    }
    
    func deleteElements(_ view: TableView<Config>, atOffsets offsets: IndexSet) {
        _ = try? root.wrappedValue.deleteItems(table: path, items: offsets)
    }
    
    func moveElements(_ view: TableView<Config>, atOffsets source: IndexSet, to destination: Int) {
        view.selection.removeAll()
        guard let sourceMin = source.min() else {
            return
        }
        _ = try? root.wrappedValue.moveItems(table: path, from: source, to: destination)
        view.value.indices.dropFirst(min(sourceMin, destination)).forEach {
            view.value[$0].index = $0
        }
    }
    
    func errors(_ view: TableView<Config>, forRow row: Int) -> [[String]] {
        return view.columns.indices.map {
            root.wrappedValue.errorBag.errors(includingDescendantsForPath: path[row][$0]).map(\.message)
        }
    }
    
    func rowView(_ view: TableView<Config>, forRow row: Int) -> TableRowView<Config> {
        let view: TableRowView<Config> = TableRowView(
            root: root,
            path: path[row],
            errors: Binding(get: { self.errors(view, forRow: row) }, set: { _ in }),
            onDelete: { self.deleteRow(view, row: row) }
        )
        return view
    }
    
}

fileprivate struct TableViewBindingViewModel<Config: AttributeViewConfig>: ListViewModelProtocol {
    
    let value: Binding<[[LineAttribute]]>
    
    let listErrors: [String] = []
    
    var latestValue: [[LineAttribute]] {
        value.wrappedValue
    }
    
    init(value: Binding<[[LineAttribute]]>) {
        self.value = value
    }
    
    func addElement(_ view: TableView<Config>) {
        value.wrappedValue.append(view.newRow)
        view.newRow = view.columns.map(\.type.defaultValue)
    }
    
    func deleteElements(_ view: TableView<Config>, atOffsets offsets: IndexSet) {
        value.wrappedValue.remove(atOffsets: offsets)
    }
    
    func moveElements(_ view: TableView<Config>, atOffsets source: IndexSet, to destination: Int) {
        view.selection.removeAll()
        guard let sourceMin = source.min() else {
            return
        }
        value.wrappedValue.move(fromOffsets: source, toOffset: destination)
        view.value.indices.dropFirst(min(sourceMin, destination)).forEach {
            view.value[$0].index = $0
        }
    }
    
    func errors(_ view: TableView<Config>, forRow _: Int) -> [[String]] {
        view.columns.map { _ in [] }
    }
    
    func rowView(_ view: TableView<Config>, forRow row: Int) -> TableRowView<Config> {
        return TableRowView<Config>(
            row: value[row],
            onDelete: { self.deleteRow(view, row: row) }
        )
    }
    
}


