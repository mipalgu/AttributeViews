/*
 * TableRowViewModel.swift
 * TableRowView
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

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// The view model associated with the `TableRowView`.
/// 
/// This view model is responsible for providing functionality related to the
/// display of a single row within a table of attributes. Generally, this
/// view model is used in conjunction with the `TableBodyViewModel`.
/// 
/// - SeeAlso: `TableRowView`.
/// - SeeAlso: `TableBodyViewModel`.
final class TableRowViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {

    /// A reference to the table.
    private let table: Ref<[[LineAttribute]]>

    /// The index of the row being displayed.
    var rowIndex: Int

    /// The viewModel associated with each column in the row.
    private var viewModels: [Int: LineAttributeViewModel] = [:]

    /// A function to fetch the view model of an attribute within the table
    /// given a row and column index.
    private let lineAttributeViewModel: (Int, Int) -> LineAttributeViewModel

    /// The row being displayed.
    var row: [LineAttribute] {
        rowIndex >= table.value.count ? [] : table.value[rowIndex]
    }

    /// Create a new `TableRowView`.
    /// 
    /// - Parameter table: A reference to the table.
    /// 
    /// - Parameter rowIndex: The index of the row being displayed.
    /// 
    /// - Parameter lineAttributeViewModel: A function to fetch the view model
    /// of an attribute within the table given a row and column index.
    init(
        table: Ref<[[LineAttribute]]>,
        rowIndex: Int,
        lineAttributeViewModel: @escaping (Int, Int) -> LineAttributeViewModel
    ) {
        self.table = table
        self.rowIndex = rowIndex
        self.lineAttributeViewModel = lineAttributeViewModel
    }

    /// Fetch the view associated with a particular column in the row.
    /// 
    /// - Parameter index: The index of the column in the row.
    /// 
    /// - Returns: The view for the attribute at the given column index.
    func view(atIndex index: Int) -> AnyView {
        guard rowIndex < table.value.count && index < table.value[rowIndex].count else {
            return AnyView(EmptyView())
        }
        if let viewModel = viewModels[index] {
            return AnyView(LineAttributeView(viewModel: viewModel))
        }
        let viewModel = self.lineAttributeViewModel(rowIndex, index)
        viewModels[index] = viewModel
        return AnyView(LineAttributeView(viewModel: viewModel))
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        viewModels = [:]
    }

}
