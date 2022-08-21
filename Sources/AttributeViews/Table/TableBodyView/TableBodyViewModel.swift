/*
 * TableBodyViewModel.swift
 * 
 *
 * Created by Callum McColl on 4/5/2022.
 * Copyright © 2022 Callum McColl. All rights reserved.
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
import Foundation
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// The view model associated with a `TableBodyView`.
/// 
/// This view model is responsible for providing CRUD (create, update, delete)
/// functionality for a table of attributes. As such, this view model
/// provides functions for adding new attributes to the table, updating the
/// table through the reordering of attributes, and deleting attributes
/// from the table.
final class TableBodyViewModel: ObservableObject, GlobalChangeNotifier {

    /// Provides access to the table associated with this view.
    private let ref: TableBodyValue

    /// The data scescribing each column of the table.
    let columns: [BlockAttributeType.TableColumn]

    /// A dictionary associating a row index of the table with a
    /// corresponding `TableRowViewModel`.
    private var rowsData: [Int: TableRowViewModel] = [:]

    /// All `TableRowViewModel`s for the table.
    var rows: [TableRowViewModel] {
        let values = ref.isValid ? ref.value : []
        return values.indices.map { row(for: $0) }
    }

    /// A set of `ObjectIdentifiers` for all `TableRowViewModel`s that'
    /// are within the selection.
    @Published var selection: Set<ObjectIdentifier> = []

    /// A `TableViewDataSource` that provides access to the data associated
    /// with the table.
    /// 
    /// - SeeAlso: KeyPathTableViewDataSource
    /// - SeeAlso: BindingTableViewDataSource
    private let dataSource: TableViewDataSource

    /// Calculate the minimum height for the table.
    var underestimatedHeight: Int {
        rows.reduce(0) { $0 + ($1.row.first?.underestimatedHeight ?? 5) } + 75
    }

    /// Create a new `TableBodyViewModel`.
    /// 
    /// This initialiser create a new `TableBodyViewModel` utilising a key
    /// path from a `Modifiable` object that contains the table that
    /// this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the table that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the table from
    /// the base `Modifiable` object.
    /// 
    /// - Parameter columns: A description of the columns within the table.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [[LineAttribute]]>,
        columns: [BlockAttributeType.TableColumn],
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = TableBodyValue(root: root, path: path, notifier: notifier)
        self.columns = columns
        self.dataSource = KeyPathTableViewDataSource<Root>(root: root, path: path, notifier: notifier)
    }

    /// Create a new `TableBodyViewModel`.
    /// 
    /// This initialiser create a new `TableBodyViewModel` utilising a
    /// reference to the table directly. It is useful to call
    /// this initialiser when utilising tables that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the table that this view model
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors associated with
    /// the table.
    /// 
    /// - Parameter columns: A description of the columns within the table.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    init(
        valueRef: Ref<[[LineAttribute]]>,
        errorsRef: ConstRef<[String]> = ConstRef(copying: []),
        columns: [BlockAttributeType.TableColumn],
        delayEdits: Bool = false
    ) {
        self.ref = TableBodyValue(valueRef: valueRef, errorsRef: errorsRef)
        self.columns = columns
        self.dataSource = BindingTableViewDataSource(ref: valueRef, delayEdits: delayEdits)
    }

    /// Fetch the view model associated with a particular row.
    /// 
    /// - Parameter index: The index of the row to fetch the view model for.
    /// 
    /// - Returns: The `TableRowViewModel` associated with the row.
    private func row(for index: Int) -> TableRowViewModel {
        guard let viewModel = rowsData[index] else {
            let viewModel = TableRowViewModel(table: ref.valueRef, rowIndex: index) {
                self.dataSource.viewModel(forElementAtRow: $0, column: $1)
            }
            rowsData[index] = viewModel
            return viewModel
        }
        return viewModel
    }

    /// Fetch any errors associated with a particular row.
    /// 
    /// - Parameter index: The index of the row to fetch the errors for.
    /// 
    /// - Returns: The errors associated with the row.
    func errors(forRow _: Int) -> [[String]] {
        columns.map { _ in [] }
    }

    /// Add a row to the table.
    /// 
    /// - Parameter newRow: The new row to add to the table.
    /// 
    /// - Attention: This triggers an `objectWillChange` notification to be
    /// sent.
    func addElement(newRow: [LineAttribute]) {
        dataSource.addElement(newRow)
        objectWillChange.send()
    }

    /// Remove a particular row from the table.
    /// 
    /// - Parameter row: The row to remove from the table.
    /// 
    /// - Attention: This triggers an `objectWillChange` notification to be
    /// sent.
    func deleteRow(row: Int) {
        guard row < rows.count else {
            return
        }
        let offsets: IndexSet = selection.contains(rows[row].id)
            ? IndexSet(selection.compactMap { id in rows.firstIndex { $0.id == id } })
            : [row]
        deleteElements(atOffsets: offsets)
    }

    /// Delete a set of rows from the table.
    /// 
    /// - Parameter offsets: The set of rows to delete from the table.
    /// 
    /// - Attention: This triggers an `objectWillChange` notification to be
    /// sent.
    func deleteElements(atOffsets offsets: IndexSet) {
        selection.removeAll()
        dataSource.deleteElements(atOffsets: offsets)
        let sorted = offsets.sorted()
        guard let minimum = sorted.first else {
            return
        }
        var decrement = 0
        for index in minimum..<rowsData.count {
            if offsets.contains(index) {
                rowsData[index] = nil
                decrement += 1
            } else {
                if decrement == 0 {
                    continue
                }
                let newIndex = index - decrement
                rowsData[index]?.rowIndex = newIndex
                rowsData[newIndex] = rowsData[index]
            }
        }
        for index in (rowsData.count - minimum - 1)..<(rowsData.count) {
            rowsData[index] = nil
        }
        objectWillChange.send()
    }

    /// Move a set of rows to a new location within the table.
    /// 
    /// The rows are moved so that the are placed directly before the element
    /// at `destination`.
    /// 
    /// - Parameter source: The set of rows to move.
    /// 
    /// - Parameter destination: The index of the element to place the rows
    /// before.
    /// 
    /// - Attention: This triggers an `objectWillChange` notification to be
    /// sent.
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        selection.removeAll()
        dataSource.moveElements(atOffsets: source, to: destination)
        var newRowsData: [(key: Int, value: TableRowViewModel)] = rowsData.sorted { $0.key < $1.key }
        newRowsData.move(fromOffsets: source, toOffset: destination)
        rowsData = Dictionary(uniqueKeysWithValues: newRowsData.enumerated().map {
            $1.value.rowIndex = $0
            return ($0, $1.value)
        })
        objectWillChange.send()
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        rowsData = [:]
    }

}
