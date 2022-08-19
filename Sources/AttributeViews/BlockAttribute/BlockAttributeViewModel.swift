/*
 * BlockAttributeViewModel.swift
 * 
 *
 * Created by Callum McColl on 24/5/21.
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

/// The view model associated wtih the `BlockAttributeView`.
/// 
/// This view model provides the data and functionality required for the
/// `BlockAttributeView`. Specifically, this view model provides the ability
/// to create type-erased views for the `BlockAttributeView`, thus hiding the
/// sub views used to display each different type of block attribute.
public final class BlockAttributeViewModel: ObservableObject, GlobalChangeNotifier {

    /// A reference to the block attribute associated with this view model.
    private let ref: BlockAttributeValue

    /// The `TableViewModel` associated with the block attribute when the
    /// attribute is a table attribute.
    lazy var tableViewModel: TableViewModel = {
        ref.tableViewModel
    }()

    /// The `ComplexViewModel` associated with the block attribute when the
    /// attribute is a complex attribute.
    lazy var complexViewModel: ComplexViewModel = {
        ref.complexViewModel
    }()

    /// The `CollectionViewModel` associated with the block attribute when the
    /// attribute is a collection attribute.
    lazy var collectionViewModel: CollectionViewModel = {
        ref.collectionViewModel
    }()

    /// The block attribute associated with this view model.
    /// 
    /// Any change made to this attribute will triggere an `objectWillChange`
    /// notification to be sent.
    var blockAttribute: BlockAttribute {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
        }
    }

    /// Create a new view for displaying the block attribute associated with
    /// this view model wrapped in an `AnyView`.
    var subView: AnyView {
        ref.subView(
            tableViewModel: tableViewModel,
            complexViewModel: complexViewModel,
            collectionViewModel: collectionViewModel
        )
    }

    /// Create a new `BlockAttributeViewModel`.
    /// 
    /// This initialiser create a new `BlockAttributeViewModel` utilising a key
    /// path from a `Modifiable` object that contains the block attribute that
    /// this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the block attribute that this view model is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the block attribute
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, BlockAttribute>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = BlockAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }

    /// Create a new `BlockAttributeViewModel`.
    /// 
    /// This initialiser create a new `BlockAttributeViewModel` utilising a
    /// reference to the block attribute directly. It is useful to call this
    /// initialiser when utilising attribute groups that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the block attribute that this
    /// view model is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that will be
    /// utilised to display errors for this block attribute.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    public init(
        valueRef: Ref<BlockAttribute>,
        errorsRef: ConstRef<[String]>,
        label: String,
        delayEdits: Bool = false
    ) {
        self.ref = BlockAttributeValue(
            valueRef: valueRef,
            errorsRef: errorsRef,
            label: label,
            delayEdits: delayEdits
        )
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    public func send() {
        objectWillChange.send()
        switch blockAttribute {
        case .table:
            tableViewModel.send()
        case .complex:
            complexViewModel.send()
        case .collection:
            collectionViewModel.send()
        default:
            break
        }
    }

}
