/*
 * BindingCollectionViewDataSource.swift
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

import Attributes
import Foundation
import GUUI

/// A `CollectionViewDataSource` that operates on a reference to a collection
/// of attributes.
struct BindingCollectionViewDataSource: CollectionViewDataSource {

    /// The reference to the collection of attributes.
    let ref: Ref<[Attribute]>

    /// Should we delay edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    let delayEdits: Bool

    /// Add a new row to the collection.
    /// 
    /// - Parameter row: The new attribute to add to the collection.
    func addElement(_ row: Attribute) {
        ref.value.append(row)
    }

    /// Remove a set of rows from the collection.
    /// 
    /// - Parameter offsets: The offsets of the rows to remove.
    func deleteElements(atOffsets offsets: IndexSet) {
        ref.value.remove(atOffsets: offsets)
    }

    /// Move a set of rows in the collection to a new place in the collection.
    /// 
    /// - Parameter source: The offsets of the rows to move.
    /// 
    /// - Parameter destination: The offset to move the rows to. The rows will
    /// be moved so that the element at `destination` is the first element that
    /// proceeds the rows at `source`.
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        ref.value.move(fromOffsets: source, toOffset: destination)
    }

    /// Fetch the view model associated with a particular row.
    /// 
    /// - Parameter row: The row to fetch the view model for.
    /// 
    /// - Returns: The view model for the row.
    func viewModel(forElementAtRow row: Int) -> AttributeViewModel {
        AttributeViewModel(valueRef: ref[row], errorsRef: ConstRef(copying: []), label: "")
    }

}
