/*
 * AttributeValue.swift
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
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// A convenience class that provides a generic way of working with
/// attributes.
final class AttributeValue: Value<Attribute> {

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `LineAttribute`.
    private let _lineAttributeViewModel: () -> LineAttributeViewModel

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `BlockAttribute`.
    private let _blockAttributeViewModel: () -> BlockAttributeViewModel

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `LineAttribute`.
    /// 
    /// - Warning: If this attribute is not a `LineAttribute` then this getter
    /// will cause a runtime error.
    var lineAttributeViewModel: LineAttributeViewModel {
        _lineAttributeViewModel()
    }

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `BlockAttribute`.
    /// 
    /// - Warning: If this attribute is not a `BlockAttribute` then this getter
    /// will cause a runtime error.
    var blockAttributeViewModel: BlockAttributeViewModel {
        _blockAttributeViewModel()
    }

    /// Create a new AttributeValue.
    /// 
    /// This initialiser utilises a key path from a root object that is
    /// `Modifiable` to the attribute that this class represents. This
    /// initialiser is generally useful when working with a `Modifiable` object
    /// that tends to change.
    /// 
    /// - Parameter root: A reference to the root `Modifiable` object.
    /// 
    /// - Parameter path: An `Attributes.Path` from the root object to the
    /// attribute.
    /// 
    /// - Parameter defaultValue: The default value to use if unable to fetch
    /// the attribute from the key path (in situations where the structure of
    /// the `Modifiable` object changes).
    /// 
    /// - Parameter label: The label used to describe the attribute (mostly
    /// utilised in views that display the attribute).
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be utilised to
    /// send a message when a trigger has been detected as firing.
    /// 
    /// - SeeAlso: `LineAttributeViewModel`.
    /// - SeeAlso: `BlockAttributeViewModel`.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, Attribute>,
        defaultValue: Attribute = .bool(false),
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(root: root, path: path.lineAttribute, label: label, notifier: notifier)
        }
        self._blockAttributeViewModel = {
            BlockAttributeViewModel(root: root, path: path.blockAttribute, label: label, notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }

    /// Create a new AttributeValue.
    /// 
    /// This initialiser utilises a `Ref` reference to an attribute. This is
    /// useful for working with temporary attributes that do not exist within
    /// a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the attribute.
    /// 
    /// - Parameter errorsRef: A const-reference to an array of error strings
    /// that will be utilised to report any errors that occur when maniupulating
    /// the attribute.
    /// 
    /// - Parameter label: The label used to describe the attribute (mostly
    /// utilised in views that display the attribute).
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    /// 
    /// - SeeAlso: `LineAttributeViewModel`.
    /// - SeeAlso: `BlockAttributeViewModel`.
    init(valueRef: Ref<Attribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(
                valueRef: valueRef.lineAttribute,
                errorsRef: ConstRef(copying: []),
                label: label,
                delayEdits: delayEdits
            )
        }
        self._blockAttributeViewModel = {
            BlockAttributeViewModel(
                valueRef: valueRef.blockAttribute,
                errorsRef: ConstRef(copying: []),
                label: label,
                delayEdits: delayEdits
            )
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

}
