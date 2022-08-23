//
/*
 * File.swift
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

/// The view model associated with the `CollectionRowView`.
/// 
/// This view model is responsible for providing functionality related to the
/// display of a single row within a collection of attributes. Generally, this
/// view model is used in conjunction with the `CollectionBodyViewModel`.
/// 
/// - SeeAlso: `CollectionRowView`.
/// - SeeAlso: `CollectionBodyViewModel`.
final class CollectionRowViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {

    /// A reference to the collection containing this row.
    private let collection: Ref<[Attribute]>

    /// The index of the row within `collection`.
    var rowIndex: Int

    /// When true, displays a sheet in `CollectionRowView` for editing the
    /// row.
    @Published var showSheet = false

    /// The view model associated with the attribute.
    private var viewModel: AttributeViewModel?

    /// A function that returns the view model associated with a given row.
    private let attributeViewModel: (Int) -> AttributeViewModel

    /// The attribute associated with this row.
    var row: Attribute {
        rowIndex >= collection.value.count ? Attribute.line("") : collection.value[rowIndex]
    }

    /// The view associated with this row.
    var view: AnyView {
        guard rowIndex < collection.value.count else {
            return AnyView(EmptyView())
        }
        if let viewModel = viewModel {
            return AnyView(AttributeView(viewModel: viewModel))
        }
        let viewModel = self.attributeViewModel(rowIndex)
        self.viewModel = viewModel
        return AnyView(AttributeView(viewModel: viewModel))
    }

    /// Create a new `CollectionRowViewModel`.
    /// 
    /// - Parameter collection: A reference to the collection containing the row
    /// associated with this view model.
    /// 
    /// - Parameter rowIndex: The index of the row within `collection`.
    /// 
    /// - Parameter attributeViewModel: A function that returns the view model
    /// associated with a given row in `collection`.
    init(
        collection: Ref<[Attribute]>,
        rowIndex: Int,
        attributeViewModel: @escaping (Int) -> AttributeViewModel
    ) {
        self.collection = collection
        self.rowIndex = rowIndex
        self.attributeViewModel = attributeViewModel
    }

    /// Set `showSheet` to false.
    func hideSheet() {
        showSheet = false
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        viewModel = nil
    }

}
