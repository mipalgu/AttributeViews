/*
 * ComplexViewModel.swift
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

/// The view model associated with the `ComplexView`.
/// 
/// The `ComplexView` represents a complex property that is composed of many
/// sub-attributes. The role of this view model is to provide access to the
/// corresponding sub-view-models associated with the sub-attributes.
/// 
/// The `ComplexView` displays each sub-attribute as a `DisclosureGroup` that
/// can be expanded or collapsed. This view model also stores data related
/// to the state of each disclosure group.
public final class ComplexViewModel: ObservableObject, GlobalChangeNotifier {

    /// A reference to the complex property that this view model is associated
    /// with.
    private let ref: ComplexValue

    /// Stores which disclosure groups are expanded or collapsed.
    private var expanded: [String: Bool] = [:]

    /// The view models associated with each attribute.
    private var attributeViewModels: [String: AttributeViewModel] = [:]

    /// The label associated with the complex property.
    @Published public var label: String

    /// A function that returns the fields associated with the complex property.
    private let getfields: () -> [Field]

    /// The fields associated with the complex property.
    public var fields: [Field] {
        getfields()
    }

    /// The errors associated with the complex property.
    var errors: [String] {
        ref.errors
    }

    /// Create a new `ComplexViewModel`.
    /// 
    /// This initialiser create a new `ComplexViewModel` utilising a key
    /// path from a `Modifiable` object that contains the complex property
    /// that this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the complex property that this view model is associated
    /// with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the complex
    /// property from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the complex
    /// property.
    /// 
    /// - Parameter fieldsPath: An `Attributes.Path` that points to the fields
    /// of the complex property from the base `Modifiable` object.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, [String: Attribute]>,
        label: String,
        fieldsPath: Attributes.Path<Root, [Field]>,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.getfields = {
            guard !fieldsPath.isNil(root.value) else {
                return []
            }
            return root.value[keyPath: fieldsPath.keyPath]
        }
        self.ref = ComplexValue(root: root, path: path, notifier: notifier)
        self.label = label
    }

    /// Create a new `ComplexViewModel`.
    /// 
    /// This initialiser create a new `ComplexViewModel` utilising a
    /// reference to the complex property directly. It is useful to call
    /// this initialiser when utilising complex properties that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the complex property that this
    /// view model is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors associated with
    /// the complex property.
    /// 
    /// - Parameter label: The label to use when presenting the complex
    /// property.
    /// 
    /// - Parameter fields: The fields associated with the complex property.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    init(
        valueRef: Ref<[String: Attribute]>,
        errorsRef: ConstRef<[String]> = ConstRef(copying: []),
        label: String,
        fields: [Field],
        delayEdits: Bool = false
    ) {
        self.getfields = {
            fields
        }
        self.ref = ComplexValue(valueRef: valueRef, errorsRef: errorsRef, delayEdits: delayEdits)
        self.label = label
    }

    /// Create a binding to a bool indicating whether the given field is
    /// expanded or not.
    /// 
    /// - Parameter fieldName: The name of the field to check.
    /// 
    /// - Returns: A binding to a bool indicating whether `fieldName` is
    /// expanded or not.
    func expandedBinding(_ fieldName: String) -> Binding<Bool> {
        Binding(
            get: { self.expanded[fieldName] ?? false },
            set: {
                self.objectWillChange.send()
                self.expanded[fieldName] = $0
            }
        )
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    public func send() {
        attributeViewModels.values.forEach {
            $0.send()
        }
        objectWillChange.send()
        sync()
    }

    /// Manually trigger an `objectWillChange` notification in all child
    /// view models.
    func sync() {
        attributeViewModels.values.forEach {
            $0.send()
        }
    }

    /// Fetch the view model associated with the given field.
    /// 
    /// - Parameter fieldName: The name of the field to fetch the view model
    /// for.
    /// 
    /// - Returns: The view model associated with the given field.
    func viewModel(forField fieldName: String) -> AttributeViewModel {
        if let viewModel = attributeViewModels[fieldName] {
            return viewModel
        }
        let viewModel = ref.viewModel(forAttribute: fieldName)
        attributeViewModels[fieldName] = viewModel
        return viewModel
    }

}
