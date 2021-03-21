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

fileprivate struct TableViewRowIDCache {
    
    static var latestIndex: Int = 0
    
    static var ids: [Row: Int] = [:]
    
    static func id(for row: Row) -> Int {
        if let id = Self.ids[row] {
            return id
        }
        let newId = latestIndex
        latestIndex += 1
        ids[row] = newId
        return newId
    }
    
}

struct Row: Hashable, Identifiable {
    
    var id: Int {
        TableViewRowIDCache.id(for: self)
    }
    
    var attributes: [LineAttribute]
    
    var subView: () -> TableRowView
    
    static func ==(lhs: Row, rhs: Row) -> Bool {
        lhs.attributes == rhs.attributes
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(attributes)
    }
    
}

public struct TableView<Root: Modifiable>: View {
    
    @Binding var root: Root
    @Binding var value: [Row]
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
                            TableRowView(
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
                        TableRowView(
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
                            LineAttributeView(attribute: $newRow[index], label: "")
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

struct TableRowView: View {
    
    let subView: (Int) -> LineAttributeView
    let row: [LineAttribute]
    let errorsForItem: (Int) -> [String]
    let onDelete: () -> Void
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, [LineAttribute]>,
        row: [LineAttribute],
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(root: root, path: path[$0], label: "")
        }
        self.row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    public init(
        value: Binding<[LineAttribute]>,
        row: [LineAttribute],
        errorsForItem: @escaping (Int) -> [String],
        onDelete: @escaping () -> Void
    ) {
        self.subView = {
            LineAttributeView(attribute: value[$0], label: "")
        }
        self.row = row
        self.errorsForItem = errorsForItem
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            ForEach(row.indices, id: \.self) { columnIndex in
                VStack {
                    subView(columnIndex)
                    ForEach(errorsForItem(columnIndex), id: \.self) { error in
                        Text(error).foregroundColor(.red)
                    }
                }
            }
            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
        }.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }
    }
}
