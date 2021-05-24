/*
 * DelayEditValueViewModel.swift
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

public final class DelayEditValueViewModel<T>: ObservableObject, GlobalChangeNotifier {
    
    private let ref: Value<T>
    
    public let label: String
    
    @Published var editing: Bool = false
    
    @Published var editValue: T
    
    let onCommit: ((T) -> Void)?
    
    var errors: [String] {
        ref.errors
    }
    
    var value: T {
        get {
            ref.value
        } set {
            ref.value = newValue
            //objectWillChange.send()
        }
    }
    
    var editingValue: T {
        get {
            nil == onCommit ? value : editValue
        } set {
            if nil == onCommit {
                value = newValue
            } else {
                editValue = newValue
            }
        }
    }
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, T>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = Value(root: root, path: path, notifier: notifier)
        self.label = label
        self.editValue = root.value[keyPath: path.keyPath]
        self.onCommit = {
            let result = root.value.modify(attribute: path, value: $0)
            switch result {
            case .success(false):
                return
            default:
                notifier?.send()
            }
        }
    }
    
    public init(valueRef: Ref<T>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), label: String, delayEdits: Bool = false) {
        self.ref = Value(valueRef: valueRef, errorsRef: errorsRef)
        self.label = label
        self.editValue = valueRef.value
        if delayEdits {
            self.onCommit = {
                valueRef.value = $0
            }
        } else {
            self.onCommit = nil
        }
    }
    
    public func send() {
        objectWillChange.send()
    }
    
    func onEditingChanged(_ editing: Bool) {
        if nil == onCommit {
            return
        }
        self.editing = editing
        if !editing {
            onCommit?(editValue)
        }
        editValue = value
    }
    
}
