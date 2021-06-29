/*
 * AttributeGroupViewModel.swift
 * 
 *
 * Created by Callum McColl on 13/5/21.
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

fileprivate final class AttributeGroupValue: Value<AttributeGroup> {
    
    private let _viewModel: () -> ComplexViewModel
    
    var viewModel: ComplexViewModel {
        _viewModel()
    }
    
    override init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, AttributeGroup>, defaultValue: AttributeGroup = AttributeGroup(name: ""), notifier: GlobalChangeNotifier? = nil) {
        self._viewModel = {
            let group = path.isNil(root.value) ? nil : root.value[keyPath: path.keyPath]
            return ComplexViewModel(root: root, path: path.attributes, label: group?.name ?? "", fields: group?.fields ?? [], notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
    }
    
    init(valueRef: Ref<AttributeGroup>, errorsRef: ConstRef<[String]>, delayEdits: Bool) {
        self._viewModel = {
            ComplexViewModel(valueRef: valueRef.attributes, label: valueRef.value.name, fields: valueRef.value.fields, delayEdits: delayEdits)
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
}

public final class AttributeGroupViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {
    
    private let ref: AttributeGroupValue
    
    lazy var complexViewModel: ComplexViewModel = {
        ref.viewModel
    }()
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, AttributeGroup>, notifier: GlobalChangeNotifier? = nil) {
        self.ref = AttributeGroupValue(root: root, path: path, notifier: notifier)
    }
    
    public init(valueRef: Ref<AttributeGroup>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), delayEdits: Bool = false) {
        self.ref = AttributeGroupValue(valueRef: valueRef, errorsRef: errorsRef, delayEdits: delayEdits)
    }
    
    public func send() {
        objectWillChange.send()
        complexViewModel.send()
    }
    
}
