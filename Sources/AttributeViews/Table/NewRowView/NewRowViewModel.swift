/*
 * NewRowViewModel.swift
 * NewRowView
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
import Foundation
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// The view model associated with a `NewRowView`.
/// 
/// This view model provides data and functionality to the `NewRowView`.
/// The `NewRowView` is responsible for managing the creation of new
/// rows for display within a `TableView`. Therefore, this view model
/// handles storing the new rows, validating the new rows, and
/// providing the new rows to the `TableBodyViewModel` when added to
/// the table.
/// 
/// - SeeAlso: `TableBodyViewModel`.
/// - SeeAlso: `NewRowView`.
/// - SeeAlso: `TableView`
final class NewRowViewModel: ObservableObject, GlobalChangeNotifier {

    /// The new row that is being created.
    @Published var newRow: [LineAttributeViewModel]

    /// An empty row that `newRow` will be set to when the user clicks the
    /// "Add" button.
    let emptyRow: [LineAttribute]

    /// Provides access to the errors associated with the new row.
    let errors: ConstRef<[[String]]>

    /// The `TableBodyViewModel` responsible for adding the new row
    /// to the table.
    let bodyViewModel: TableBodyViewModel

    /// Create a new `NewRowViewModel`.
    /// 
    /// - Parameter newRow: The new row that is being created.
    /// 
    /// - Parameter emptyRow: An empty row that represents the default
    /// value for the new row when all of the fields are empty.
    /// 
    /// - Parameter errors: A reference to the errors associated with the new
    /// row.
    /// 
    /// - Parameter bodyViewModel: The `TableBodyViewModel` responsible for
    /// managing the table attribute.
    init(
        newRow: [LineAttribute],
        emptyRow: [LineAttribute],
        errors: ConstRef<[[String]]>,
        bodyViewModel: TableBodyViewModel
    ) {
        self.newRow = newRow.map {
            LineAttributeViewModel(valueRef: Ref(copying: $0), errorsRef: ConstRef(copying: []), label: "")
        }
        self.emptyRow = emptyRow
        self.errors = errors
        self.bodyViewModel = bodyViewModel
    }

    /// Add the new row to the table.
    func addElement() {
        bodyViewModel.addElement(newRow: newRow.map(\.lineAttribute))
        zip(newRow, emptyRow).forEach {
            $0.lineAttribute = $1
        }
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        newRow.forEach {
            $0.send()
        }
    }

}
