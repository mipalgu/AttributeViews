/*
 * AttributeViewModel.swift
 * 
 *
 * Created by Callum McColl on 1/5/21.
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

/// The view model associated with `AttributeView`.
public final class AttributeViewModel: ObservableObject, GlobalChangeNotifier {

    /// A reference to the attribute that this view model is associated with.
    private let ref: AttributeValue

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `LineAttribute`.
    /// 
    /// - Warning: If this attribute is not a `LineAttribute` then this getter
    /// will cause a runtime error.
    lazy var lineAttributeViewModel: LineAttributeViewModel = {
        ref.lineAttributeViewModel
    }()

    /// A getter that returns the view model associated with this attribute
    /// when this attribute is a `BlockAttribute`.
    /// 
    /// - Warning: If this attribute is not a `BlockAttribute` then this getter
    /// will cause a runtime error.
    lazy var blockAttributeViewModel: BlockAttributeViewModel = {
        ref.blockAttributeViewModel
    }()

    /// The attribute associated with this view model.
    /// 
    /// - Attention: Calling the setter of the property causes this view model
    /// to publish an `objectWillChange` notification.
    var attribute: Attribute {
        get {
            ref.value
        } set {
            ref.value = newValue
            objectWillChange.send()
        }
    }

    /// The view associated with the attribute associated wtih this view model.
    /// 
    /// The view returned will either be a `LineAttributeView` or a
    /// `BlockAttributeView` depending on whether the attribute referenced
    /// by this view model is a line attribute or a block attribute
    /// respectively.
    var subView: AnyView {
        switch ref.value.type {
        case .block:
            return AnyView(BlockAttributeView(viewModel: ref.blockAttributeViewModel))
        case .line:
            return AnyView(LineAttributeView(viewModel: ref.lineAttributeViewModel))
        }
    }

    /// Create a new `AttributeViewModel`.
    /// 
    /// This initialiser create a new `AttributeViewModel` utilising a key path
    /// from a `Modifiable` object that contains the attribute that this view
    /// model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the attribute that this view model is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the attribute
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to display for the attribute.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, Attribute>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = AttributeValue(root: root, path: path, label: label, notifier: notifier)
    }

    /// Create a new `AttributeViewModel`.
    /// 
    /// This initialiser create a new `AttributeViewModel` utilising a reference
    /// to the attribute directly. It is useful to call this initialiser when
    /// utilising attributes that do not exist within a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the attribute that this view model
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that will be
    /// utilised to display errors for this attribute.
    /// 
    /// - Parameter label: The label to display for the attribute.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    public init(
        valueRef: Ref<Attribute>,
        errorsRef: ConstRef<[String]> = ConstRef(copying: []),
        label: String,
        delayEdits: Bool = false
    ) {
        self.ref = AttributeValue(
            valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits
        )
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// in the `blockAttributeViewModel` or `lineAttributeViewModel` depending
    /// on whether the attribute referenced by this view model is a
    /// `LineAttribute` or a `BlockAttribute` respectively.
    public func send() {
        objectWillChange.send()
        if ref.value.isBlock {
            blockAttributeViewModel.send()
        } else {
            lineAttributeViewModel.send()
        }
    }

}
