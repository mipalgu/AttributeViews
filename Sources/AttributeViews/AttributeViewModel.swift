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
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Attribute>, defaultValue: Attribute = .bool(false), label: String, notifier: GlobalChangeNotifier? = nil) {
        self._lineAttributeViewModel = {
            LineAttributeViewModel(root: root, path: path.lineAttribute, label: label, notifier: notifier)
        }
        self._blockAttributeViewModel = {
            BlockAttributeViewModel(root: root, path: path.blockAttribute, label: label, notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
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
        get {
            ref.value
        } set {
            ref.value = newValue
            objectWillChange.send()
        }
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
        if ref.value.isBlock {
            blockAttributeViewModel.send()
        } else {
            lineAttributeViewModel.send()
        }
    }
    
}
