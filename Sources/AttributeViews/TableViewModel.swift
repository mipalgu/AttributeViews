/*
 * TableViewModel.swift
 * 
 *
 * Created by Callum McColl on 2/5/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

final class TableViewModel<Config: AttributeViewConfig>: ObservableObject {
    
    let newRowViewModel: NewRowViewModel<Config>
    
    let tableBodyViewModel: TableBodyViewModel<Config>
    
    private let errors: Binding<[String]>
    
    var listErrors: [String] {
        errors.wrappedValue
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn], notifier: GlobalChangeNotifier? = nil) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel<Config>(root: root, path: path, columns: columns, notifier: notifier)
        self.newRowViewModel = NewRowViewModel(newRow: emptyRow, emptyRow: emptyRow, errors: .constant(columns.map { _ in [] }), bodyViewModel: bodyViewModel)
        self.tableBodyViewModel = bodyViewModel
        self.errors = Binding(
            get: { root.wrappedValue.errorBag.errors(forPath: path).map(\.message) },
            set: { _ in }
        )
    }
    
    init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]>, subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String], columns: [BlockAttributeType.TableColumn], delayEdits: Bool = false) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel<Config>(value: value, subErrors: subErrors, columns: columns, delayEdits: delayEdits)
        self.newRowViewModel = NewRowViewModel(newRow: emptyRow, emptyRow: emptyRow, errors: .constant(columns.map { _ in [] }), bodyViewModel: bodyViewModel)
        self.tableBodyViewModel = bodyViewModel
        self.errors = errors
    }
    
}

final class NewRowViewModel<Config: AttributeViewConfig>: ObservableObject {
    
    @Published var newRow: [LineAttribute]
    
    let emptyRow: [LineAttribute]
    
    let errors: Binding<[[String]]>
    
    let bodyViewModel: TableBodyViewModel<Config>
    
    init(newRow: [LineAttribute], emptyRow: [LineAttribute], errors: Binding<[[String]]>, bodyViewModel: TableBodyViewModel<Config>) {
        self.newRow = newRow
        self.emptyRow = emptyRow
        self.errors = errors
        self.bodyViewModel = bodyViewModel
    }
    
    func addElement() {
        bodyViewModel.addElement(newRow: newRow)
        newRow = emptyRow
    }
    
}

final class TableBodyViewModel<Config: AttributeViewConfig>: ObservableObject {
    
    private let valueBinding: Binding<[[LineAttribute]]>
    let subErrors: (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String]
    let columns: [BlockAttributeType.TableColumn]
    
    @Published var rows: [TableRowViewModel] = []
    @Published var selection: Set<ObjectIdentifier> = []
    
    private let dataSource: TableViewDataSource
    
    var value: [[LineAttribute]] {
        get {
            valueBinding.wrappedValue
        } set {
            valueBinding.wrappedValue = newValue
            objectWillChange.send()
        }
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn], notifier: GlobalChangeNotifier? = nil) {
        self.valueBinding = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: { _ = root.wrappedValue.modify(attribute: path, value: $0) }
        )
        self.subErrors = {
            root.wrappedValue.errorBag.errors(forPath: ReadOnlyPath(keyPath: path.keyPath.appending(path: $0.keyPath), ancestors: [])).map(\.message)
        }
        self.columns = columns
        self.dataSource = KeyPathTableViewDataSource<Root, Config>(root: root, path: path, notifier: notifier)
        syncRows()
    }
    
    init(value: Binding<[[LineAttribute]]>, subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String], columns: [BlockAttributeType.TableColumn], delayEdits: Bool = false) {
        self.valueBinding = value
        self.subErrors = subErrors
        self.columns = columns
        self.dataSource = BindingTableViewDataSource<Config>(value: value, delayEdits: delayEdits)
        syncRows()
    }
    
    func errors(forRow _: Int) -> [[String]] {
        columns.map { _ in [] }
    }
    
    func addElement(newRow: [LineAttribute]) {
        dataSource.addElement(newRow)
        syncRows()
        objectWillChange.send()
    }
    
    func deleteRow(row: Int) {
        guard row < value.count else {
            return
        }
        let offsets: IndexSet = selection.contains(rows[row].id)
            ? IndexSet(selection.compactMap { id in rows.firstIndex { $0.id == id } })
            : [row]
        dataSource.deleteElements(atOffsets: offsets)
        syncRows()
        objectWillChange.send()
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        dataSource.deleteElements(atOffsets: offsets)
        syncRows()
        objectWillChange.send()
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        selection.removeAll()
        dataSource.moveElements(atOffsets: source, to: destination)
        syncRows()
        objectWillChange.send()
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
                    lineAttributeView: {
                        self.dataSource.view(forElementAtRow: $0, column: $1)
                    }
                )
            })
        }
    }
    
}


fileprivate protocol TableViewDataSource {
    
    func addElement(_ row: [LineAttribute])
    func deleteElements(atOffsets offsets: IndexSet)
    func moveElements(atOffsets source: IndexSet, to destination: Int)
    func view(forElementAtRow row: Int, column: Int) -> AnyView
    
}

fileprivate struct KeyPathTableViewDataSource<Root: Modifiable, Config: AttributeViewConfig>: TableViewDataSource {
    
    let root: Binding<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>
    weak var notifier: GlobalChangeNotifier?
    
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
        AnyView(LineAttributeView<Config>(root: root, path: path[row][column], label: "", notifier: notifier))
    }
    
}

fileprivate struct BindingTableViewDataSource<Config: AttributeViewConfig>: TableViewDataSource {
    
    let value: Binding<[[LineAttribute]]>
    
    let delayEdits: Bool
    
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
            label: "",
            delayEdits: delayEdits
        ))
    }
    
}
