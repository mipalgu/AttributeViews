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
import Foundation
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// The view model associated with a `TableView`.
/// 
/// This view model provides data and functionality to the `TableView`.
/// The `TableView` is responsible for displaying a table of
/// attributes. This view model therefore provides CRUD (create, update, delete)
/// functionality for that table of attributes.
public final class TableViewModel: ObservableObject, GlobalChangeNotifier {

    /// The view model that provides the functionality for creating a new row
    /// within a `TableView`.
    let newRowViewModel: NewRowViewModel

    /// The view model associated with managing the table of attributes.
    let tableBodyViewModel: TableBodyViewModel

    /// The label of the table.
    let label: String

    /// Provides access to errors associated with the table.
    private let errorsRef: ConstRef<[String]>

    /// The errors associated with the table.
    var listErrors: [String] {
        errorsRef.value
    }

    /// Create a new `TableViewModel`.
    /// 
    /// This initialiser create a new `TableViewModel` utilising a key
    /// path from a `Modifiable` object that contains the table
    /// that this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the table that this view model is associated
    /// with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the table
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the table.
    /// 
    /// - Parameter columns: A description of the columns within the table.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [[LineAttribute]]>,
        label: String,
        columns: [BlockAttributeType.TableColumn],
        notifier: GlobalChangeNotifier? = nil
    ) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel(root: root, path: path, columns: columns, notifier: notifier)
        self.newRowViewModel = NewRowViewModel(
            newRow: emptyRow,
            emptyRow: emptyRow,
            errors: ConstRef(copying: columns.map { _ in [] }),
            bodyViewModel: bodyViewModel
        )
        self.tableBodyViewModel = bodyViewModel
        self.label = label
        self.errorsRef = ConstRef { root.value.errorBag.errors(forPath: path).map(\.message) }
    }

    /// Create a new `TableViewModel`.
    /// 
    /// This initialiser create a new `TableViewModel` utilising a
    /// reference to the table directly. It is useful to call
    /// this initialiser when utilising tables that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the table that this
    /// view model is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that are
    /// associated with the table.
    /// 
    /// - Parameter label: The label to use when presenting the table.
    /// 
    /// - Parameter columns: A description of the columns within the table.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    public init(
        valueRef: Ref<[[LineAttribute]]>,
        errorsRef: ConstRef<[String]>,
        label: String,
        columns: [BlockAttributeType.TableColumn],
        delayEdits: Bool = false
    ) {
        let emptyRow = columns.map(\.type.defaultValue)
        let bodyViewModel = TableBodyViewModel(
            valueRef: valueRef,
            errorsRef: ConstRef(copying: []),
            columns: columns,
            delayEdits: delayEdits
        )
        self.newRowViewModel = NewRowViewModel(
            newRow: emptyRow,
            emptyRow: emptyRow,
            errors: ConstRef(copying: columns.map { _ in [] }),
            bodyViewModel: bodyViewModel
        )
        self.tableBodyViewModel = bodyViewModel
        self.label = label
        self.errorsRef = errorsRef
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    public func send() {
        objectWillChange.send()
        newRowViewModel.send()
        tableBodyViewModel.send()
    }

}
