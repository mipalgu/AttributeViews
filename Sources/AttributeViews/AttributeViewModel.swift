/*
 * AttributeViewModel.swift
 * 
 *
 * Created by Callum McColl on 1/5/21.
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

fileprivate final class AttributeValue: Value<Attribute> {
    
    private let _lineAttributeViewModel: () -> LineAttributeViewModel
    
    private let _blockAttributeViewModel: () -> BlockAttributeViewModel
    
    var lineAttributeViewModel: LineAttributeViewModel {
        _lineAttributeViewModel()
    }
    
    var blockAttributeViewModel: BlockAttributeViewModel {
        _blockAttributeViewModel()
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Attribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(root: root, path: path.lineAttribute, label: label, notifier: notifier)
        }
        self._blockAttributeViewModel = {
            BlockAttributeViewModel(root: root, path: path.blockAttribute, label: label, notifier: notifier)
        }
        super.init(root: root, path: path, notifier: notifier)
    }
    
    init(valueRef: Ref<Attribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(valueRef: valueRef.lineAttribute, errorsRef: ConstRef(copying: []), label: label, delayEdits: delayEdits)
        }
        self._blockAttributeViewModel = {
            BlockAttributeViewModel(valueRef: valueRef.blockAttribute, errorsRef: ConstRef(copying: []), label: label, delayEdits: delayEdits)
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
}

public final class AttributeViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: AttributeValue
    
    lazy var lineAttributeViewModel: LineAttributeViewModel = {
        ref.lineAttributeViewModel
    }()
    
    lazy var blockAttributeViewModel: BlockAttributeViewModel = {
        ref.blockAttributeViewModel
    }()
    
    var attribute: Attribute {
        ref.value
    }
    
    var subView: AnyView {
        switch ref.value.type {
        case .block:
            return AnyView(BlockAttributeView(viewModel: ref.blockAttributeViewModel))
        case .line:
            return AnyView(LineAttributeView(viewModel: ref.lineAttributeViewModel))
        }
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Attribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = AttributeValue(root: root, path: path, label: label, notifier: notifier)
    }
    
    public init(valueRef: Ref<Attribute>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), label: String, delayEdits: Bool = false) {
        self.ref = AttributeValue(valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
    }
    
    public func send() {
        objectWillChange.send()
        if !ref.isValid {
            return
        }
        if ref.value.isBlock {
            blockAttributeViewModel = ref.blockAttributeViewModel
        } else {
            lineAttributeViewModel = ref.lineAttributeViewModel
        }
    }
    
}

fileprivate final class BlockAttributeValue: Value<BlockAttribute> {
    
    private let _tableViewModel: () -> TableViewModel
    
    private let _complexViewModel: () -> ComplexViewModel
    
    private let _subView: (TableViewModel, ComplexViewModel) -> AnyView
    
    var tableViewModel: TableViewModel {
        _tableViewModel()
    }
    
    var complexViewModel: ComplexViewModel {
        _complexViewModel()
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
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
                return ComplexViewModel(root: root, path: path.complexValue, label: label, fields: [], notifier: notifier)
            }
            let fields: [Field]
            switch root.value[keyPath: path.keyPath].type {
            case .complex(let layout):
                fields = layout
            default:
                fields = []
            }
            return ComplexViewModel(root: root, path: path.complexValue, label: label, fields: fields, notifier: notifier)
        }
        self._subView = { (tableViewModel, complexViewModel) in
            switch root.value[keyPath: path.keyPath].type {
            case .code(let language):
                return AnyView(CodeView(root: root.asBinding, path: path.codeValue, label: label, language: language, notifier: notifier))
            case .text:
                return AnyView(TextView(root: root.asBinding, path: path.textValue, label: label, notifier: notifier))
            case .collection(let type):
                return AnyView(EmptyView())
                //return AnyView(CollectionView(root: root.asBinding, path: path.collectionValue, display: root.value[keyPath: path.keyPath].collectionDisplay, label: label, type: type, expanded: .constant([:]), notifier: notifier))
            case .table(let columns):
                return AnyView(TableView(viewModel: tableViewModel))
            case .complex(let fields):
                return AnyView(ComplexView(viewModel: complexViewModel))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(root: root.asBinding, path: path.enumerableCollectionValue, label: label, validValues: validValues, notifier: notifier))
            }
        }
        super.init(root: root, path: path, notifier: notifier)
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
            ComplexViewModel(valueRef: valueRef.complexValue, label: label, fields: valueRef.value.complexFields)
        }
        self._subView = { (tableViewModel, complexViewModel) in
            switch valueRef.value.type {
            case .code(let language):
                return AnyView(CodeView(value: valueRef.codeValue.asBinding, label: label, language: language, delayEdits: delayEdits))
            case .text:
                return AnyView(TextView(value: valueRef.textValue.asBinding, label: label, delayEdits: delayEdits))
            case .collection(let type):
                return AnyView(EmptyView())
                //return AnyView(CollectionView(value: valueRef.collectionValue.asBinding, display: valueRef.value.collectionDisplay, label: label, type: type, delayEdits: delayEdits))
            case .table(let columns):
                return AnyView(TableView(viewModel: tableViewModel))
            case .complex(let fields):
                return AnyView(ComplexView(viewModel: complexViewModel))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(value: valueRef.enumerableCollectionValue.asBinding, label: label, validValues: validValues))
            }
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func subView(tableViewModel: TableViewModel, complexViewModel: ComplexViewModel) -> AnyView {
        _subView(tableViewModel, complexViewModel)
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
    
    var blockAttribute: BlockAttribute {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
        }
    }
    
    var subView: AnyView {
        ref.subView(tableViewModel: tableViewModel, complexViewModel: complexViewModel)
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = BlockAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }
    
    public init(valueRef: Ref<BlockAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool = false) {
        self.ref = BlockAttributeValue(valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
    }
    
    public func send() {
        objectWillChange.send()
        tableViewModel = ref.tableViewModel
        complexViewModel = ref.complexViewModel
    }
    
}

fileprivate final class LineAttributeValue: Value<LineAttribute> {
    
    private let _subView: () -> AnyView
    
    var subView: AnyView {
        _subView()
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, LineAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self._subView = {
            if path.isNil(root.value) {
                return AnyView(EmptyView())
            }
            switch root.value[keyPath: path.keyPath].type {
            case .bool:
                return AnyView(BoolView(root: root.asBinding, path: path.boolValue, label: label, notifier: notifier))
            case .integer:
                return AnyView(IntegerView(root: root.asBinding, path: path.integerValue, label: label, notifier: notifier))
            case .float:
                return AnyView(FloatView(root: root.asBinding, path: path.floatValue, label: label, notifier: notifier))
            case .expression(let language):
                return AnyView(ExpressionView(root: root.asBinding, path: path.expressionValue, label: label, language: language, notifier: notifier))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView(root: root.asBinding, path: path.enumeratedValue, label: label, validValues: validValues, notifier: notifier))
            case .line:
                return AnyView(LineView(root: root.asBinding, path: path.lineValue, label: label, notifier: notifier))
            }
        }
        super.init(root: root, path: path, notifier: notifier)
    }
    
    init(valueRef: Ref<LineAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool) {
        self._subView = {
            switch valueRef.value.type {
            case .bool:
                return AnyView(BoolView(value: valueRef.boolValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label))
            case .integer:
                return AnyView(IntegerView(value: valueRef.integerValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label, delayEdits: delayEdits))
            case .float:
                return AnyView(FloatView(value: valueRef.floatValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label, delayEdits: delayEdits))
            case .expression(let language):
                return AnyView(ExpressionView(value: valueRef.expressionValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label, language: language, delayEdits: delayEdits))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView(value: valueRef.enumeratedValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label, validValues: validValues))
            case .line:
                return AnyView(LineView(value: valueRef.lineValue.asBinding, errors: errorsRef.asReadOnlyBinding, label: label, delayEdits: delayEdits))
            }
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
}

public final class LineAttributeViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {
    
    private let ref: LineAttributeValue
    
    var lineAttribute: LineAttribute {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
        }
    }
    
    var lineAttributeBinding: Binding<LineAttribute> {
        Binding(
            get: { self.lineAttribute },
            set: { self.lineAttribute = $0 }
        )
    }
    
    var boolValue: Bool {
        get {
            ref.value.boolValue
        } set {
            ref.value.boolValue = newValue
            objectWillChange.send()
        }
    }
    
    var integerValue: Int {
        get {
            ref.value.integerValue
        } set {
            ref.value.integerValue = newValue
            objectWillChange.send()
        }
    }
    
    var floatValue: Double {
        get {
            ref.value.floatValue
        } set {
            ref.value.floatValue = newValue
        }
    }
    
    var expressionValue: Expression {
        get {
            ref.value.expressionValue
        } set {
            ref.value.expressionValue = newValue
            objectWillChange.send()
        }
    }
    
    var enumeratedValue: String {
        get {
            ref.value.enumeratedValue
        } set {
            ref.value.enumeratedValue = newValue
            objectWillChange.send()
        }
    }
    
    var lineValue: String {
        get {
            ref.value.lineValue
        } set {
            ref.value.lineValue = newValue
            objectWillChange.send()
        }
    }
    
    var subView: AnyView {
        ref.subView
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, LineAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = LineAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }
    
    public init(valueRef: Ref<LineAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool = false) {
        self.ref = LineAttributeValue(valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
    }
    
    public func send() {
        objectWillChange.send()
    }
    
}

extension LineAttributeViewModel: Hashable {
    
    public static func ==(lhs: LineAttributeViewModel, rhs: LineAttributeViewModel) -> Bool {
        lhs.lineAttribute == rhs.lineAttribute
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lineAttribute)
    }
    
}
