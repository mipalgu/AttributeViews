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

public final class TableViewModel: ObservableObject, GlobalChangeNotifier {
    
    let newRowViewModel: NewRowViewModel
    
    let tableBodyViewModel: TableBodyViewModel
    
    let label: String
    
    private let errorsRef: ConstRef<[String]>
    
    var listErrors: [String] {
        errorsRef.value
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn], notifier: GlobalChangeNotifier? = nil) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel(root: root, path: path, columns: columns, notifier: notifier)
        self.newRowViewModel = NewRowViewModel(newRow: emptyRow, emptyRow: emptyRow, errors: ConstRef(copying: columns.map { _ in [] }), bodyViewModel: bodyViewModel)
        self.tableBodyViewModel = bodyViewModel
        self.label = label
        self.errorsRef = ConstRef(
            get: { root.value.errorBag.errors(forPath: path).map(\.message) }
        )
    }
    
    public init(valueRef: Ref<[[LineAttribute]]>, errorsRef: ConstRef<[String]>, label: String, columns: [BlockAttributeType.TableColumn], delayEdits: Bool = false) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel(valueRef: valueRef, errorsRef: ConstRef(copying: []), columns: columns, delayEdits: delayEdits)
        self.newRowViewModel = NewRowViewModel(newRow: emptyRow, emptyRow: emptyRow, errors: ConstRef(copying: columns.map { _ in [] }), bodyViewModel: bodyViewModel)
        self.tableBodyViewModel = bodyViewModel
        self.label = label
        self.errorsRef = errorsRef
    }
    
    public func send() {
        objectWillChange.send()
        newRowViewModel.send()
        tableBodyViewModel.send()
    }
    
}

final class NewRowViewModel: ObservableObject, GlobalChangeNotifier {
    
    @Published var newRow: [LineAttributeViewModel]
    
    let emptyRow: [LineAttribute]
    
    let errors: ConstRef<[[String]]>
    
    let bodyViewModel: TableBodyViewModel
    
    init(newRow: [LineAttribute], emptyRow: [LineAttribute], errors: ConstRef<[[String]]>, bodyViewModel: TableBodyViewModel) {
        self.newRow = newRow.map {
            LineAttributeViewModel(valueRef: Ref(copying: $0), errorsRef: ConstRef(copying: []), label: "")
        }
        self.emptyRow = emptyRow
        self.errors = errors
        self.bodyViewModel = bodyViewModel
    }
    
    func addElement() {
        bodyViewModel.addElement(newRow: newRow.map(\.lineAttribute))
        zip(newRow, emptyRow).forEach {
            $0.lineAttribute = $1
        }
    }
    
    func send() {
        objectWillChange.send()
        newRow.forEach {
            $0.send()
        }
    }
    
}

fileprivate final class TableBodyValue: Value<[[LineAttribute]]> {
    
    private let _lineAttributeViewModel: (Int, Int) -> LineAttributeViewModel
    
    override init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, notifier: GlobalChangeNotifier? = nil) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(root: root, path: path[$0][$1], label: "", notifier: notifier)
        }
        super.init(root: root, path: path, notifier: notifier)
    }
    
    override init(valueRef: Ref<[[LineAttribute]]>, errorsRef: ConstRef<[String]>) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(valueRef: valueRef[$0][$1], errorsRef: ConstRef(copying: []), label: "")
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func viewModel(forRow row: Int) -> TableRowViewModel {
        TableRowViewModel(table: valueRef, rowIndex: row, lineAttributeViewModel: _lineAttributeViewModel)
    }
    
}

final class TableBodyViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: TableBodyValue
    let columns: [BlockAttributeType.TableColumn]
    
    @Published var rows: [TableRowViewModel] = []
    @Published var selection: Set<ObjectIdentifier> = []
    
    private let dataSource: TableViewDataSource
    
    var value: [[LineAttribute]] {
        get {
            if ref.isValid {
                return ref.value
            } else {
                return []
            }
        } set {
            ref.value = newValue
            objectWillChange.send()
        }
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, columns: [BlockAttributeType.TableColumn], notifier: GlobalChangeNotifier? = nil) {
        self.ref = TableBodyValue(root: root, path: path, notifier: notifier)
        self.columns = columns
        self.dataSource = KeyPathTableViewDataSource<Root>(root: root, path: path, notifier: notifier)
        syncRows()
    }
    
    init(valueRef: Ref<[[LineAttribute]]>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), columns: [BlockAttributeType.TableColumn], delayEdits: Bool = false) {
        self.ref = TableBodyValue(valueRef: valueRef, errorsRef: errorsRef)
        self.columns = columns
        self.dataSource = BindingTableViewDataSource(ref: valueRef, delayEdits: delayEdits)
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
                    table: ref.valueRef,
                    rowIndex: row,
                    lineAttributeViewModel: {
                        self.dataSource.viewModel(forElementAtRow: $0, column: $1)
                    }
                )
            })
        }
    }
    
    func send() {
        objectWillChange.send()
        rows.forEach {
            $0.send()
        }
    }
    
}


fileprivate protocol TableViewDataSource {
    
    func addElement(_ row: [LineAttribute])
    func deleteElements(atOffsets offsets: IndexSet)
    func moveElements(atOffsets source: IndexSet, to destination: Int)
    func viewModel(forElementAtRow row: Int, column: Int) -> LineAttributeViewModel
    
}

fileprivate struct KeyPathTableViewDataSource<Root: Modifiable>: TableViewDataSource {
    
    let root: Ref<Root>
    let path: Attributes.Path<Root, [[LineAttribute]]>
    weak var notifier: GlobalChangeNotifier?
    
    func addElement(_ row: [LineAttribute]) {
        _ = root.value.addItem(row, to: path)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        _ = root.value.deleteItems(table: path, items: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        _ = root.value.moveItems(table: path, from: source, to: destination)
    }
    
    func viewModel(forElementAtRow row: Int, column: Int) -> LineAttributeViewModel {
        LineAttributeViewModel(root: root, path: path[row][column], label: "", notifier: notifier)
    }
    
}

fileprivate struct BindingTableViewDataSource: TableViewDataSource {
    
    let ref: Ref<[[LineAttribute]]>
    
    let delayEdits: Bool
    
    func addElement(_ row: [LineAttribute]) {
        ref.value.append(row)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        ref.value.remove(atOffsets: offsets)
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        ref.value.move(fromOffsets: source, toOffset: destination)
    }
    
    func viewModel(forElementAtRow row: Int, column: Int) -> LineAttributeViewModel {
        LineAttributeViewModel(valueRef: ref[row][column], errorsRef: ConstRef(copying: []), label: "")
    }
    
}
