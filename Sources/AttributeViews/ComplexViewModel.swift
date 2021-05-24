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

final class ComplexValue: Value<[String: Attribute]> {
    
    private let _viewModel: (String) -> AttributeViewModel
    
    override init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, notifier: GlobalChangeNotifier? = nil) {
        self._viewModel = { AttributeViewModel(root: root, path: path[$0].wrappedValue, label: $0, notifier: notifier) }
        super.init(root: root, path: path, notifier: notifier)
    }
    
    init(valueRef: Ref<[String: Attribute]>, errorsRef: ConstRef<[String]>, delayEdits: Bool) {
        self._viewModel = { AttributeViewModel(valueRef: valueRef[$0].wrappedValue, errorsRef: ConstRef(copying: []), label: $0, delayEdits: delayEdits) }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func viewModel(forAttribute attribute: String) -> AttributeViewModel {
        self._viewModel(attribute)
    }
    
}

public final class ComplexViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: ComplexValue
    
    private var expanded: [String: Bool] = [:]
    
    private var attributeViewModels: [String: AttributeViewModel] = [:]
    
    @Published public var label: String
    
    @Published public var fields: [Field]
    
    var errors: [String] {
        ref.errors
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field], notifier: GlobalChangeNotifier? = nil) {
        self.ref = ComplexValue(root: root, path: path, notifier: notifier)
        self.label = label
        self.fields = fields
    }
    
    init(valueRef: Ref<[String: Attribute]>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), label: String, fields: [Field], delayEdits: Bool = false) {
        self.ref = ComplexValue(valueRef: valueRef, errorsRef: errorsRef, delayEdits: delayEdits)
        self.label = label
        self.fields = fields
    }
    
    func expandedBinding(_ fieldName: String) -> Binding<Bool> {
        return Binding(
            get: { self.expanded[fieldName] ?? false },
            set: { self.expanded[fieldName] = $0 }
        )
    }
    
    public func send() {
        objectWillChange.send()
        self.attributeViewModels = [:]
    }
    
    func viewModel(forField fieldName: String) -> AttributeViewModel {
        if let viewModel = attributeViewModels[fieldName] {
            return viewModel
        }
        let viewModel = ref.viewModel(forAttribute: fieldName)
        attributeViewModels[fieldName] = viewModel
        return viewModel
    }
    
}
