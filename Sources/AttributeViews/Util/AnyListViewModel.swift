/*
 * AnyListViewModel.swift
 * AttributeViews
 *
 * Created by Callum McColl on 15/4/21.
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

import Foundation

struct AnyListViewModel<View, RowData, RowView, ErrorData>: ListViewModelProtocol {
    
    private let _listErrors: () -> [String]
    private let _latestValue: () -> [RowData]
    private let _newRow: () -> RowData
    private let _addElement: (View) -> Void
    private let _deleteRow: (View, Int) -> Void
    private let _deleteElements: (View, IndexSet) -> Void
    private let _moveElements: (View, IndexSet, Int) -> Void
    private let _errors: (View, Int) -> [ErrorData]
    private let _rowView: (View, Int) -> RowView
    
    
    var listErrors: [String] {
        self._listErrors()
    }
    
    var latestValue: [RowData] {
        self._latestValue()
    }
    
    var newRow: RowData {
        self._newRow()
    }
    
    init<ViewModel: ListViewModelProtocol>(_ viewModel: ViewModel) where ViewModel.View == View, ViewModel.RowData == RowData, ViewModel.RowView == RowView, ViewModel.ErrorData == ErrorData {
        self._listErrors = { viewModel.listErrors }
        self._latestValue = { viewModel.latestValue }
        self._newRow = { viewModel.newRow }
        self._addElement = viewModel.addElement
        self._deleteRow = viewModel.deleteRow
        self._deleteElements = viewModel.deleteElements
        self._moveElements = viewModel.moveElements
        self._errors = viewModel.errors
        self._rowView = viewModel.rowView
    }
    
    func addElement(_ view: View) {
        self._addElement(view)
    }
    
    func deleteRow(_ view: View, row: Int) {
        self._deleteRow(view, row)
    }
    
    func deleteElements(_ view: View, atOffsets offsets: IndexSet) {
        self._deleteElements(view, offsets)
    }
    
    func moveElements(_ view: View, atOffsets source: IndexSet, to destination: Int) {
        self._moveElements(view, source, destination)
    }
    
    func errors(_ view: View, forRow row: Int) -> [ErrorData] {
        self._errors(view, row)
    }
    
    func rowView(_ view: View, forRow row: Int) -> RowView {
        self._rowView(view, row)
    }
    
}
