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

fileprivate final class BlockAttributeValue: Value<BlockAttribute> {
    
    private let _tableViewModel: () -> TableViewModel
    
    private let _complexViewModel: () -> ComplexViewModel
    
    private let _collectionViewModel: () -> CollectionViewModel
    
    private let _subView: (TableViewModel, ComplexViewModel, CollectionViewModel) -> AnyView
    
    var tableViewModel: TableViewModel {
        _tableViewModel()
    }
    
    var complexViewModel: ComplexViewModel {
        _complexViewModel()
    }
    
    var collectionViewModel: CollectionViewModel {
        _collectionViewModel()
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, BlockAttribute>, defaultValue: BlockAttribute = .text(""), label: String, notifier: GlobalChangeNotifier? = nil) {
        self._tableViewModel = {
            if path.isNil(root.value) {
                return TableViewModel(root: root, path: path.tableValue, label: label, columns: [], notifier: notifier)
            }
            let columns: [BlockAttributeType.TableColumn]
            switch root.value[keyPath: path.keyPath].type {
            case .table(let cols):
                columns = cols
            default:
                return TableViewModel(valueRef: Ref(copying: []), errorsRef: ConstRef(copying: []), label: label, columns: [])
            }
            return TableViewModel(root: root, path: path.tableValue, label: label, columns: columns, notifier: notifier)
        }
        self._complexViewModel = {
            if path.isNil(root.value) {
                return ComplexViewModel(root: root, path: path.complexValue, label: label, fieldsPath: path.complexFields, notifier: notifier)
            }
            return ComplexViewModel(root: root, path: path.complexValue, label: label, fieldsPath: path.complexFields, notifier: notifier)
        }
        self._collectionViewModel = {
            if path.isNil(root.value) {
                return CollectionViewModel(root: root, path: path.collectionValue, label: label, type: .bool, notifier: notifier)
            }
            let type: AttributeType
            switch root.value[keyPath: path.keyPath].type {
            case .collection(let subType):
                type = subType
            default:
                type = .bool
            }
            return CollectionViewModel(root: root, path: path.collectionValue, label: label, type: type, notifier: notifier)
        }
        self._subView = { (tableViewModel, complexViewModel, collectionViewModel) in
            switch root.value[keyPath: path.keyPath].type {
            case .code(let language):
                return AnyView(CodeView(root: root.asBinding, path: path.codeValue, label: label, language: language, notifier: notifier))
            case .text:
                return AnyView(TextView(root: root.asBinding, path: path.textValue, label: label, notifier: notifier))
            case .collection:
                return AnyView(CollectionView(viewModel: collectionViewModel))
            case .table:
                return AnyView(TableView(viewModel: tableViewModel))
            case .complex:
                return AnyView(ComplexView(viewModel: complexViewModel))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(root: root.asBinding, path: path.enumerableCollectionValue, label: label, validValues: validValues, notifier: notifier))
            }
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }
    
    init(valueRef: Ref<BlockAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool) {
        self._tableViewModel = {
            let columns: [BlockAttributeType.TableColumn]
            switch valueRef.value.type {
            case .table(let cols):
                columns = cols
            default:
                columns = []
            }
            return TableViewModel(valueRef: valueRef.tableValue, errorsRef: ConstRef(copying: []), label: label, columns: columns, delayEdits: delayEdits)
        }
        self._complexViewModel = {
            let fields: [Field]
            switch valueRef.value.type {
            case .complex(let flds):
                fields = flds
            default:
                fields = []
            }
            return ComplexViewModel(valueRef: valueRef.complexValue, label: label, fields: fields)
        }
        self._collectionViewModel = {
            let type: AttributeType
            switch valueRef.value.type {
            case .collection(let subType):
                type = subType
            default:
                type = .bool
            }
            return CollectionViewModel(valueRef: valueRef.collectionValue, errorsRef: ConstRef(copying: []), label: label, type: type, delayEdits: delayEdits)
        }
        self._subView = { (tableViewModel, complexViewModel, collectionViewModel) in
            switch valueRef.value.type {
            case .code(let language):
                return AnyView(CodeView(value: valueRef.codeValue.asBinding, label: label, language: language, delayEdits: delayEdits))
            case .text:
                return AnyView(TextView(value: valueRef.textValue.asBinding, label: label, delayEdits: delayEdits))
            case .collection:
                return AnyView(CollectionView(viewModel: collectionViewModel))
                //return AnyView(CollectionView(value: valueRef.collectionValue.asBinding, display: valueRef.value.collectionDisplay, label: label, type: type, delayEdits: delayEdits))
            case .table:
                return AnyView(TableView(viewModel: tableViewModel))
            case .complex:
                return AnyView(ComplexView(viewModel: complexViewModel))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(value: valueRef.enumerableCollectionValue.asBinding, label: label, validValues: validValues))
            }
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func subView(tableViewModel: TableViewModel, complexViewModel: ComplexViewModel, collectionViewModel: CollectionViewModel) -> AnyView {
        _subView(tableViewModel, complexViewModel, collectionViewModel)
    }
    
}

public final class BlockAttributeViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: BlockAttributeValue
    
    lazy var tableViewModel: TableViewModel = {
        ref.tableViewModel
    }()
    
    lazy var complexViewModel: ComplexViewModel = {
        ref.complexViewModel
    }()
    
    lazy var collectionViewModel: CollectionViewModel = {
        ref.collectionViewModel
    }()
    
    var blockAttribute: BlockAttribute {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
        }
    }
    
    var subView: AnyView {
        ref.subView(tableViewModel: tableViewModel, complexViewModel: complexViewModel, collectionViewModel: collectionViewModel)
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = BlockAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }
    
    public init(valueRef: Ref<BlockAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool = false) {
        self.ref = BlockAttributeValue(valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
    }
    
    public func send() {
        objectWillChange.send()
        tableViewModel.send()
        complexViewModel.send()
        collectionViewModel.send()
    }
    
}
