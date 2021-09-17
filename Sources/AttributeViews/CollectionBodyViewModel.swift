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
import TokamakShim
import Foundation
#else
import SwiftUI
#endif

import Attributes
import GUUI

final class CollectionBodyValue: Value<[Attribute]> {
    
    private let _attributeViewModel: (Int) -> AttributeViewModel
    
    override init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [Attribute]>, defaultValue: [Attribute] = [], notifier: GlobalChangeNotifier? = nil) {
        self._attributeViewModel = {
            AttributeViewModel(root: root, path: path[$0], label: "", notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }
    
    override init(valueRef: Ref<[Attribute]>, errorsRef: ConstRef<[String]>) {
        self._attributeViewModel = {
            AttributeViewModel(valueRef: valueRef[$0], errorsRef: ConstRef(copying: []), label: "")
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func viewModel(forRow row: Int) -> CollectionRowViewModel {
        CollectionRowViewModel(collection: valueRef, rowIndex: row, attributeViewModel: _attributeViewModel)
    }
    
}

final class CollectionBodyViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: CollectionBodyValue
    
    let type: AttributeType
    
    private var rowsData: [Int: CollectionRowViewModel] = [:]
    
    var rows: [CollectionRowViewModel] {
        let values = ref.isValid ? ref.value : []
        return values.indices.map { row(for: $0) }
    }
    
    @Published var selection: Set<ObjectIdentifier> = []
    
    private let dataSource: CollectionViewDataSource
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [Attribute]>, type: AttributeType, notifier: GlobalChangeNotifier? = nil) {
        self.ref = CollectionBodyValue(root: root, path: path, notifier: notifier)
        self.type = type
        self.dataSource = KeyPathCollectionViewDataSource<Root>(root: root, path: path, notifier: notifier)
    }
    
    init(valueRef: Ref<[Attribute]>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), type: AttributeType, delayEdits: Bool = false) {
        self.ref = CollectionBodyValue(valueRef: valueRef, errorsRef: errorsRef)
        self.type = type
        self.dataSource = BindingCollectionViewDataSource(ref: valueRef, delayEdits: delayEdits)
    }
    
    private func row(for index: Int) -> CollectionRowViewModel {
        guard let viewModel = rowsData[index] else {
            let viewModel = CollectionRowViewModel(collection: ref.valueRef, rowIndex: index, attributeViewModel: {
                self.dataSource.viewModel(forElementAtRow: $0)
            })
            rowsData[index] = viewModel
            return viewModel
        }
        return viewModel
    }
    
    func errors(forRow _: Int) -> [String] {
        []
    }
    
    func addElement(newRow: Attribute) {
        dataSource.addElement(newRow)
        objectWillChange.send()
    }
    
    func deleteRow(row: Int) {
        guard row < rows.count else {
            return
        }
        let offsets: IndexSet = selection.contains(rows[row].id)
            ? IndexSet(selection.compactMap { id in rows.firstIndex { $0.id == id } })
            : [row]
        deleteElements(atOffsets: offsets)
    }
    
    func deleteElements(atOffsets offsets: IndexSet) {
        selection.removeAll()
        dataSource.deleteElements(atOffsets: offsets)
        let sorted = offsets.sorted()
        guard let minimum = sorted.first else {
            return
        }
        var decrement = 0
        for index in minimum..<rowsData.count {
            if offsets.contains(index) {
                rowsData[index] = nil
                decrement += 1
            } else {
                if decrement == 0 {
                    continue
                }
                let newIndex = index - decrement
                rowsData[index]?.rowIndex = newIndex
                rowsData[newIndex] = rowsData[index]
            }
        }
        for index in (rowsData.count - minimum - 1)..<(rowsData.count) {
            rowsData[index] = nil
        }
        objectWillChange.send()
    }
    
    func moveElements(atOffsets source: IndexSet, to destination: Int) {
        selection.removeAll()
        dataSource.moveElements(atOffsets: source, to: destination)
        var newRowsData: [(key: Int, value: CollectionRowViewModel)] = rowsData.sorted { $0.key < $1.key }
        newRowsData.move(fromOffsets: source, toOffset: destination)
        rowsData = Dictionary(uniqueKeysWithValues: newRowsData.enumerated().map {
            $1.value.rowIndex = $0
            return ($0, $1.value)
        })
        objectWillChange.send()
    }
    
    func send() {
        objectWillChange.send()
        rowsData = [:]
    }
    
}
