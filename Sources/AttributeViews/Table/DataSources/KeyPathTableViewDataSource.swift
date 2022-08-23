/*
 * KeyPathTableViewDataSource.swift
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

/// A `TableViewDataSource` that operates on a keypath to an array of rows
/// that exists within a base `Modifiable` object.
struct KeyPathTableViewDataSource<Root: Modifiable>: TableViewDataSource {

    /// A reference to the base `Modifiable` object that
    /// contains the rows that this data source is associated with.
    let root: Ref<Root>

    /// An `Attributes.Path` that points to the rows from `root`.
    let path: Attributes.Path<Root, [[LineAttribute]]>

    /// A `GlobalChangeNotifier` that will be used to notify any listeners when
    /// a trigger is fired.
    weak var notifier: GlobalChangeNotifier?

    /// Add a new row to the table.
    /// 
    /// - Parameter row: The new attribute to add to the table.
    func addElement(_ row: [LineAttribute]) {
        _ = root.value.addItem(row, to: path)
    }

    /// Remove a set of rows from the table.
    /// 
    /// - Parameter offsets: The offsets of the rows to remove.
    func deleteElements(atOffsets offsets: IndexSet) {
        _ = root.value.deleteItems(table: path, items: offsets)
    }

    /// Move a set of rows in the table to a new place in the table.
    /// 
    /// - Parameter source: The offsets of the rows to move.
    /// 
    /// - Parameter destination: The offset to move the rows to. The rows will
    /// be moved so that the element at `destination` is the first element that
    /// proceeds the rows at `source`.
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        _ = root.value.moveItems(table: path, from: source, to: destination)
    }

    /// Fetch the view model associated with a particular row.
    /// 
    /// - Parameter row: The row to fetch the view model for.
    /// 
    /// - Returns: The view model for the row.
    func viewModel(forElementAtRow row: Int, column: Int) -> LineAttributeViewModel {
        LineAttributeViewModel(root: root, path: path[row][column], label: "", notifier: notifier)
    }

}
