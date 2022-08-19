/*
 * AttributeGroupValue.swift
 * AttributeGroups
 *
 * Created by Callum McColl on 19/8/22.
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

import Attributes
import GUUI

/// A convenience class for working with an `AttributeGroup`.
final class AttributeGroupValue: Value<AttributeGroup> {

    /// A getter for retrieving the `ComplexViewModel` associated with the
    /// group.
    private let _viewModel: () -> ComplexViewModel

    /// A getter for retrieving the `ComplexViewModel` associated with the
    /// group.
    /// 
    /// - SeeAlso: `ComplexViewModel`.
    var viewModel: ComplexViewModel {
        _viewModel()
    }

    /// Create a new `AttributeGroupValue`.
    /// 
    /// This initialiser create a new `AttributeGroupValue` utilising a key path
    /// from a `Modifiable` object that contains the attribute group that this
    /// class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the attribute group that this class is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the attribute group
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// `AttributeGroupe` if the group sieces to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the group is deleted.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    override init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, AttributeGroup>,
        defaultValue: AttributeGroup = AttributeGroup(name: ""),
        notifier: GlobalChangeNotifier? = nil
    ) {
        self._viewModel = {
            let group = path.isNil(root.value) ? nil : root.value[keyPath: path.keyPath]
            return ComplexViewModel(
                root: root,
                path: path.attributes,
                label: group?.name ?? "",
                fieldsPath: path.fields,
                notifier: notifier
            )
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }

    /// Create a new `AttributeGroupValue`.
    /// 
    /// This initialiser create a new `AttributeGroupValue` utilising a
    /// reference to the attribute group directly. It is useful to call this
    /// initialiser when utilising attribute groups that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the attribute group that this class
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that will be
    /// utilised to display errors for this attribute group.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    init(valueRef: Ref<AttributeGroup>, errorsRef: ConstRef<[String]>, delayEdits: Bool) {
        self._viewModel = {
            ComplexViewModel(
                valueRef: valueRef.attributes,
                label: valueRef.value.name,
                fields: valueRef.value.fields,
                delayEdits: delayEdits
            )
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

}
