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

public struct TableView<Config: AttributeViewConfig, Root: Modifiable>: View {
    
    @Binding var root: Root
    @Binding var value: [Row<Config>]
    @State var errors: [String] = []
    let label: String
    let columns: [BlockAttributeType.TableColumn]
    
    @State var newRow: [LineAttribute]
    @State var selection: Set<Int>
    
    let addElement: () -> Void
    let deleteElements: (IndexSet) -> Void
    let moveElements: (IndexSet, Int) -> Void
    let errorsForItem: (Int, Int) -> [String]
    let tableErrors: () -> [String]
    let latestValue: () -> [[LineAttribute]]
    
    @EnvironmentObject var config: Config
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self._root = root
        let errors = State<[String]>(initialValue: root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message })
        self._errors = errors
        let selection = State<Set<Int>>(initialValue: [])
        self._selection = selection
        let errorsForItem: (Int, Int) -> [String] = { (row, col) in
            root.wrappedValue.errorBag.errors(forPath: AnyPath(path[row][col])).map(\.message)
        }
        let deleteOffsets: (IndexSet) -> Void = { (offsets) in
            _ = try? root.wrappedValue.deleteItems(table: path, items: offsets)
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
        }
        let deleteElement: (Int) -> Void = { (index) in
            guard index < root.wrappedValue[keyPath: path.keyPath].count else {
                return
            }
            let offsets: IndexSet = selection.wrappedValue.contains(index)
                ? IndexSet(selection.wrappedValue)
                : [index]
            deleteOffsets(offsets)
        }
        self._value = Binding(
            get: {
                root.wrappedValue[keyPath: path.keyPath].enumerated().map { (index, row) in
                    Row(
                        attributes: row,
                        subView: {
                            TableRowView<Config>(
                                root: root,
                                path: path[index],
                                row: row,
                                errorsForItem: { errorsForItem(index, $0) },
                                onDelete: { deleteElement(index) }
                            )
                        }
                    )
                }
            },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0.map(\.attributes))
                errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
            }
        )
        self.label = label
        self.columns = columns
        let newRow = State<[LineAttribute]>(initialValue: columns.map { $0.type.defaultValue })
        self._newRow = newRow
        self.addElement = {
            _ = try? root.wrappedValue.addItem(newRow.wrappedValue, to: path)
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
        }
        self.deleteElements = deleteOffsets
        self.moveElements = { (source, destination) in
            _ = try? root.wrappedValue.moveItems(table: path, from: source, to: destination)
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
        }
        self.tableErrors = {
            root.wrappedValue.errorBag.errors(includingDescendantsForPath: path).map(\.message)
        }
        self.errorsForItem = errorsForItem
        self.latestValue = { root.wrappedValue[keyPath: path.keyPath] }
    }
    
    init(root: Binding<Root>, value: Binding<[[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self._root = root
        let errors = State<[String]>(initialValue: [])
        self._errors = errors
        let selection = State<Set<Int>>(initialValue: [])
        self._selection = selection
        let deleteOffsets: (IndexSet) -> Void = { (offsets) in
            value.wrappedValue.remove(atOffsets: offsets)
        }
        let deleteElement: (Int) -> Void = { (index) in
            guard index < value.wrappedValue.count else {
                return
            }
            let offsets: IndexSet = selection.wrappedValue.contains(index)
                ? IndexSet(selection.wrappedValue)
                : [index]
            deleteOffsets(offsets)
        }
        self._value = Binding(
            get: {
                value.wrappedValue.enumerated().map { (index, row) in
                    Row(attributes: row, subView: {
                        TableRowView<Config>(
                            value: value[index],
                            row: row,
                            errorsForItem: { _ in [] },
                            onDelete: { deleteElement(index) }
                        )
                    })
                }
            },
            set: {
                value.wrappedValue = $0.map { $0.attributes }
            }
        )
        self.label = label
        self.columns = columns
        let newRow = State<[LineAttribute]>(initialValue: columns.map { $0.type.defaultValue })
        self._newRow = newRow
        self.addElement = {
            value.wrappedValue.append(newRow.wrappedValue)
            newRow.wrappedValue = columns.map { $0.type.defaultValue }
        }
        self.deleteElements = deleteOffsets
        self.moveElements = { (source, destination) in
            value.wrappedValue.move(fromOffsets: source, toOffset: destination)
        }
        self.tableErrors = { [] }
        self.errorsForItem = { (_, _) in [] }
        self.latestValue = { value.wrappedValue }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.pretty.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            List(selection: $selection) {
                Section(header: VStack {
                    HStack {
                        ForEach(columns, id: \.name) { column in
                            Text(column.name.pretty)
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        Text("").frame(width: 15)
                    }
                    ForEach(errors, id: \.self) { error in
                        Text(error).foregroundColor(.red)
                    }
                }, content: {
                    ForEach(value) { row in
                        row.subView()
                    }.onMove(perform: moveElements).onDelete(perform: deleteElements)
                })
            }.frame(minHeight: CGFloat(28 * value.count + 70))
            ScrollView([.vertical], showsIndicators: false) {
                HStack {
                    ForEach(newRow.indices) { index in
                        VStack {
                            LineAttributeView<Config>(attribute: $newRow[index], label: "")
                            ForEach(errorsForItem(value.count, index), id: \.self) { error in
                                Text(error).foregroundColor(.red)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Button(action: addElement, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle())
                      .foregroundColor(.blue)
                      .frame(width: 15)
                }
            }.padding(.top, -35).padding(.leading, 15).padding(.trailing, 18).frame(height: 50)
        }
    }

}

fileprivate struct TableViewRowIDCache {
    
    static var latestIndex: Int = 0
    
    static var ids: [[LineAttribute]: Int] = [:]
    
    static func id<Config>(for row: Row<Config>) -> Int {
        if let id = Self.ids[row.attributes] {
            return id
        }
        let newId = latestIndex
        latestIndex += 1
        ids[row.attributes] = newId
        return newId
    }
    
}

struct Row<Config: AttributeViewConfig>: Hashable, Identifiable {
    
    var id: Int {
        TableViewRowIDCache.id(for: self)
    }
    
    var attributes: [LineAttribute]
    
    var subView: () -> TableRowView<Config>
    
    static func ==(lhs: Row, rhs: Row) -> Bool {
        lhs.attributes == rhs.attributes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(attributes)
    }
    
}

import Machines

struct TableView_Previews: PreviewProvider {
    
    struct TableViewRoot_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        let config = DefaultAttributeViewsConfig()
        
        let path = Machine.path
            .attributes[0]
            .attributes["machine_variables"]
            .wrappedValue
            .tableValue
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig, Machine>(
                root: $machine,
                path: path,
                label: "Root",
                columns: [
                    .init(name: "Access Type", type: .enumerated(validValues: ["let", "var"])),
                    .init(name: "Label", type: .line),
                    .init(name: "Type", type: .expression(language: .swift)),
                    .init(name: "Initial Value", type: .expression(language: .swift))
                ]
            ).environmentObject(config)
        }
        
    }
    
    struct TableViewBinding_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var value: [[LineAttribute]] = []
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig, Machine>(
                root: $machine,
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
            TableViewRoot_Preview()
            TableViewBinding_Preview()
        }
    }
}
