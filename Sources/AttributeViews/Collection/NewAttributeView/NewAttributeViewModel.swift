/*
 * NewAttributeViewModel.swift
 * 
 *
 * Created by Callum McColl on 18/9/21.
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

/// The view model associated with a `NewAttributeView`.
/// 
/// This view model provides data and functionality to the `NewAttributeView`.
/// The `NewAttributeView` is responsible for managing the creation of new
/// attributes for display within a `CollectionView`. Therefore, this view model
/// handles storing the new attribute, validating the new attribute, and
/// providing the new attribute to the `CollectionBodyViewModel` when added to
/// the collection.
/// 
/// - SeeAlso: `CollectionBodyViewModel`.
/// - SeeAlso: `NewAttributeView`.
/// - SeeAlso: `CollectionView`
final class NewAttributeViewModel: ObservableObject, GlobalChangeNotifier {

    /// The new attribute that is being created.
    @Published var newRow: AttributeViewModel

    /// When true, the `NewAttributeView` displays a sheet contianing the fields
    /// for creating the new attribute.
    @Published var showSheet = false

    /// An empty attribute that the attribute associated with `newRow` will be
    /// set to when the user clicks the "Add" button.
    let emptyRow: Attribute

    /// Provides access to the errors associated with the new attribute.
    let errors: ConstRef<[String]>

    /// The `CollectionBodyViewModel` responsible for adding the new attribute
    /// to the collection.
    let bodyViewModel: CollectionBodyViewModel

    /// Create a new `NewAttributeViewModel`.
    /// 
    /// - Parameter newRow: The new attribute that is being created.
    /// 
    /// - Parameter emptyRow: An empty attribute that represents the default
    /// value for the new attribute when all of the fields are empty.
    /// 
    /// - Parameter errors: A reference to the errors associated with the new
    /// attribute.
    /// 
    /// - Parameter bodyViewModel: The `CollectionBodyViewModel` responsible for
    /// managing the collection attribute.
    init(
        newRow: Attribute,
        emptyRow: Attribute,
        errors: ConstRef<[String]>,
        bodyViewModel: CollectionBodyViewModel
    ) {
        self.newRow = AttributeViewModel(
            valueRef: Ref(copying: newRow),
            errorsRef: ConstRef(copying: []),
            label: ""
        )
        self.emptyRow = emptyRow
        self.errors = errors
        self.bodyViewModel = bodyViewModel
    }

    /// Add the new attribute to the collection.
    func addElement() {
        bodyViewModel.addElement(newRow: newRow.attribute)
        newRow.attribute = emptyRow
        showSheet = false
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        newRow.send()
    }

}
