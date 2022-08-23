/*
 * ComplexValue.swift
 * Complex
 *
 * Created by Callum McColl on 21/8/22.
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

/// A convenience class for working with a `ComplexValue`.
/// 
/// A complex value represents a dictionary where the keys are a string and the
/// values are an `Attribute`. This class provides functionality to fetch
/// `AttributeViewModel`s for each key in the dictionary.
final class ComplexValue: Value<[String: Attribute]> {

    /// A fucntion that fetches a view model given a key.
    private let _viewModel: (String) -> AttributeViewModel

    /// Create a new `ComplexValue`.
    /// 
    /// This initialiser create a new `ComplexValue` utilising a key path
    /// from a `Modifiable` object that contains the complex property that this
    /// class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the complex property that this class is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the complex
    /// property from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// complex property if the complex property ceases to exist. This is
    /// necessary to prevent `SwiftUi` crashes during animations when the
    /// complex property is deleted.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    override init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [String: Attribute]>,
        defaultValue: [String: Attribute] = [:],
        notifier: GlobalChangeNotifier? = nil
    ) {
        self._viewModel = {
            AttributeViewModel(root: root, path: path[$0].wrappedValue, label: $0, notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }

    /// Create a new `ComplexValue`.
    /// 
    /// This initialiser create a new `ComplexValue` utilising a
    /// reference to the complex property directly. It is useful to call this
    /// initialiser when utilising complex properties that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the complex property that this
    /// class is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors associated with
    /// the complex property.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    init(valueRef: Ref<[String: Attribute]>, errorsRef: ConstRef<[String]>, delayEdits: Bool) {
        self._viewModel = {
            AttributeViewModel(
                valueRef: valueRef[$0].wrappedValue,
                errorsRef: ConstRef(copying: []),
                label: $0,
                delayEdits: delayEdits
            )
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

    /// Fetch a view model for a specific attribute.
    /// 
    /// - Parameter attribute: The name of the attribute for the view model to
    /// fetch.
    /// 
    /// - Returns: The `AttributeViewModel` associated with the attribute.
    func viewModel(forAttribute attribute: String) -> AttributeViewModel {
        self._viewModel(attribute)
    }

}
