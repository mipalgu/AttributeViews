/*
 * ListViewModelProtocol.swift
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

protocol ListViewModelProtocol {
    
    associatedtype View
    associatedtype RowData
    associatedtype RowView
    associatedtype ErrorData
    
    var listErrors: [String] { get }
    
    var latestValue: [RowData] { get }
    
    var newRow: RowData { get }
    
    func addElement(_ view: View)
    func deleteRow(_ view: View, row: Int)
    func deleteElements(_ view: View, atOffsets offsets: IndexSet)
    func moveElements(_ view: View, atOffsets source: IndexSet, to destination: Int)
    func errors(_ view: View, forRow row: Int) -> [ErrorData]
    func rowView(_ view: View, forRow row: Int) -> RowView
    
}

extension ListViewModelProtocol where View: ListViewProtocol, View.RowData == RowData {
    
    func deleteRow(_ view: View, row: Int) {
        guard row < view.value.count else {
            return
        }
        let offsets: IndexSet = view.selection.contains(row)
            ? IndexSet(view.selection)
            : [row]
        self.deleteElements(view, atOffsets: offsets)
    }
    
}

extension ListViewModelProtocol where View: ListViewProtocol, Self: RootPathContainer, Self.PathData == [RowData], View.RowData == RowData {
    
    var listErrors: [String] {
        root.wrappedValue.errorBag.errors(includingDescendantsForPath: path).map(\.message)
    }
    
    var latestValue: [RowData] {
        root.wrappedValue[keyPath: path.keyPath]
    }
    
    func addElement(_ view: View) {
        try? root.wrappedValue.addItem(view.newRow, to: path)
    }
    
    func deleteElements(_ view: View, atOffsets offsets: IndexSet) {
        _ = try? root.wrappedValue.deleteItems(table: path, items: offsets)
    }
    
    func moveElements(_ view: View, atOffsets source: IndexSet, to destination: Int) {
        view.selection.removeAll()
        guard let sourceMin = source.min() else {
            return
        }
        _ = try? root.wrappedValue.moveItems(table: path, from: source, to: destination)
        view.value.indices.dropFirst(min(sourceMin, destination)).forEach {
            view.value[$0].index = $0
        }
    }
    
    
}

extension ListViewModelProtocol where View: ListViewProtocol, Self: ValueErrorsContainer, View.RowData == RowData, Value == [RowData] {
    
    var listErrors: [String] {
        errors.wrappedValue
    }
    
    var latestValue: [RowData] {
        value.wrappedValue
    }
    
    func addElement(_ view: View) {
        value.wrappedValue.append(view.newRow)
        view.newRow = self.newRow
    }
    
    func deleteElements(_ view: View, atOffsets offsets: IndexSet) {
        value.wrappedValue.remove(atOffsets: offsets)
    }
    
    func moveElements(_ view: View, atOffsets source: IndexSet, to destination: Int) {
        view.selection.removeAll()
        guard let sourceMin = source.min() else {
            return
        }
        value.wrappedValue.move(fromOffsets: source, toOffset: destination)
        view.value.indices.dropFirst(min(sourceMin, destination)).forEach {
            view.value[$0].index = $0
        }
    }
    
}
