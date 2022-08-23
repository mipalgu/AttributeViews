/*
 * CollectionBodyValue.swift
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
import GUUI

/// A convenience class for working with a collection of attributes.
/// 
/// This class simply provides a means for accessing a `CollectionRowViewModel`
/// for each row within a collection of attributes. Thus, a
/// `CollectionRowViewModel` is associated with each attribute within the
/// collection that this view model manages.
final class CollectionBodyValue: Value<[Attribute]> {

    /// A function for returning a view model for a given attribute at a given
    /// index.
    private let _attributeViewModel: (Int) -> AttributeViewModel

    /// Create a new `CollectionBodyValue`.
    /// 
    /// This initialiser create a new `CollectionBodyValue` utilising a key path
    /// from a `Modifiable` object that contains the collection of attributes
    /// that this class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the collection that this class is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the collection from
    /// the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// collection if the collection ceases to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the attribute is
    /// deleted.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    override init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [Attribute]>,
        defaultValue: [Attribute] = [],
        notifier: GlobalChangeNotifier? = nil
    ) {
        self._attributeViewModel = {
            AttributeViewModel(root: root, path: path[$0], label: "", notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }

    /// Create a new `CollectionBodyValue`.
    /// 
    /// This initialiser create a new `CollectionBodyValue` utilising a
    /// reference to the collection directly. It is useful to call this
    /// initialiser when utilising collections that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the collection that this class
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that will be
    /// utilised to display errors for this collection.
    override init(valueRef: Ref<[Attribute]>, errorsRef: ConstRef<[String]>) {
        self._attributeViewModel = {
            AttributeViewModel(valueRef: valueRef[$0], errorsRef: ConstRef(copying: []), label: "")
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

    /// Fetch the view model associated with a particular row within the
    /// collection.
    /// 
    /// - Parameter row: The index of the row to fetch the view model for.
    /// 
    /// - Returns: The `CollectionRowViewModel` associated with the row.
    func viewModel(forRow row: Int) -> CollectionRowViewModel {
        CollectionRowViewModel(collection: valueRef, rowIndex: row, attributeViewModel: _attributeViewModel)
    }

}
