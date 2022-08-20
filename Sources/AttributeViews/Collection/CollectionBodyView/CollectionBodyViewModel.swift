//
/*
 * File.swift
 * 
 *
 * Created by Callum McColl on 18/9/21.
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
import Foundation
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// The view model associated with a `CollectionBodyView`.
/// 
/// This view model is responsible for providing CRUD (create, update, delete)
/// functionality for a collection of attributes. As such, this view model
/// provides functions for adding new attributes to the collection, updating the
/// collection through the reordering of attributes, and deleting attributes
/// from the collection.
final class CollectionBodyViewModel: ObservableObject, GlobalChangeNotifier {

    /// Provides access to the collection associated with this view.
    private let ref: CollectionBodyValue

    /// The type of the attributes contained within the collection.
    let type: AttributeType

    /// A dictionary associating the index of the collection with a
    /// corresponding `CollectionRowViewModel`.
    private var rowsData: [Int: CollectionRowViewModel] = [:]

    /// All `CollectionRowViewModel`s for the collection.
    var rows: [CollectionRowViewModel] {
        let values = ref.isValid ? ref.value : []
        return values.indices.map { row(for: $0) }
    }

    /// A set of `ObjectIdentifiers` for all `CollectionRowViewModel`s that'
    /// are within the selection.
    @Published var selection: Set<ObjectIdentifier> = []

    /// A `CollectionViewDataSource` that provides access to the data associated
    /// with the collection.
    /// 
    /// - SeeAlso: KeyPathCollectionViewDataSource
    /// - SeeAlso: BindingCollectionViewDataSource
    private let dataSource: CollectionViewDataSource

    /// Create a new `CollectionBodyViewModel`.
    /// 
    /// This initialiser create a new `CollectionBodyViewModel` utilising a key
    /// path from a `Modifiable` object that contains the collection that
    /// this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the collection that this view model is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the collection from
    /// the base `Modifiable` object.
    /// 
    /// - Parameter type: The type of the attributes contained within the
    /// collection.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [Attribute]>,
        type: AttributeType,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = CollectionBodyValue(root: root, path: path, notifier: notifier)
        self.type = type
        self.dataSource = KeyPathCollectionViewDataSource<Root>(root: root, path: path, notifier: notifier)
    }

    /// Create a new `CollectionBodyViewModel`.
    /// 
    /// This initialiser create a new `CollectionBodyViewModel` utilising a
    /// reference to the collection directly. It is useful to call
    /// this initialiser when utilising collections that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the collection that this view model
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that will be
    /// utilised to display errors for this collection.
    /// 
    /// - Parameter type: The type of the attributes contained within the
    /// collection.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    init(
        valueRef: Ref<[Attribute]>,
        errorsRef: ConstRef<[String]> = ConstRef(copying: []),
        type: AttributeType,
        delayEdits: Bool = false
    ) {
        self.ref = CollectionBodyValue(valueRef: valueRef, errorsRef: errorsRef)
        self.type = type
        self.dataSource = BindingCollectionViewDataSource(ref: valueRef, delayEdits: delayEdits)
    }

    /// Fetch the view model associated with a particular row.
    /// 
    /// - Parameter index: The index of the row to fetch the view model for.
    /// 
    /// - Returns: The `CollectionRowViewModel` associated with the row.
    private func row(for index: Int) -> CollectionRowViewModel {
        guard let viewModel = rowsData[index] else {
            // swiftlint:disable unowned_variable_capture
            let viewModel = CollectionRowViewModel(
                collection: ref.valueRef,
                rowIndex: index
            ) { [unowned self] in
                self.dataSource.viewModel(forElementAtRow: $0)
            }
            // swiftlint:enable unowned_variable_capture
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
    func errors(forRow _: Int) -> [String] {
        []
    }

    /// Add an attribute to the collection.
    /// 
    /// - Parameter attribute: The attribute to add to the collection.
    /// 
    /// - Attention: This triggers an `objectWillChange` notification to be
    /// sent.
    func addElement(newRow: Attribute) {
        dataSource.addElement(newRow)
        objectWillChange.send()
    }

    /// Remove a particular row from the collection.
    /// 
    /// - Parameter row: The row to remove from the collection.
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

    /// Delete a set of rows from the collection.
    /// 
    /// - Parameter offsets: The set of rows to delete from the collection.
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

    /// Move a set of rows to a new location within the collection.
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
        var newRowsData: [(key: Int, value: CollectionRowViewModel)] = rowsData.sorted { $0.key < $1.key }
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
