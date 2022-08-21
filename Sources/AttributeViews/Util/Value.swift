/*
 * Value.swift
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

import Attributes
import GUUI

/// A convenience class for working with values that have associated errors.
/// 
/// Generally, when working with attributes, you will want to use the `Value`
/// class (or one of its subclasses) to tie a value to a set of errors. This
/// class is a convenience class that provides functionality for values that
/// have associated errors.
class Value<Value> {

    /// A function that returns whether the value is valid.
    private let _isValid: () -> Bool

    /// A reference to the value.
    let valueRef: Ref<Value>

    /// A const-reference to the errors associated with the value.
    let errorsRef: ConstRef<[String]>

    /// Is the value valid?
    var isValid: Bool {
        _isValid()
    }

    /// The value associated with this class.
    var value: Value {
        get {
            valueRef.value
        } set {
            valueRef.value = newValue
        }
    }

    /// the errors associated with `value`.
    var errors: [String] {
        errorsRef.value
    }

    /// Create a new `Value`.
    /// 
    /// This initialiser create a new `Value` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this class is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the value
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// value if the value ceases to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the value is
    /// deleted.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, Value>,
        defaultValue: Value,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.valueRef = Ref(
            get: {
                path.isNil(root.value) ? defaultValue : root.value[keyPath: path.keyPath]
            },
            set: {
                let result = root.value.modify(attribute: path, value: $0)
                switch result {
                case .success(false):
                    return
                default:
                    notifier?.send()
                }
            }
        )
        self.errorsRef = ConstRef {
            root.value.errorBag.errors(forPath: path).map(\.message)
        }
        self._isValid = { !path.isNil(root.value) }
    }

    /// Create a new `Value`.
    /// 
    /// This initialiser create a new `Value` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this class is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to an optional that
    /// contains the value from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// value if the value ceases to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the value is
    /// deleted.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, Value?>,
        defaultValue: Value,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.valueRef = Ref(
            get: {
                path.isNil(root.value) ? defaultValue : (root.value[keyPath: path.keyPath] ?? defaultValue)
            },
            set: {
                let result = root.value.modify(attribute: path, value: $0)
                switch result {
                case .success(false):
                    return
                default:
                    notifier?.send()
                }
            }
        )
        self.errorsRef = ConstRef {
            root.value.errorBag.errors(forPath: path).map(\.message)
        }
        self._isValid = { !path.isNil(root.value) }
    }

    /// Create a new `Value`.
    /// 
    /// This initialiser create a new `Value` utilising a
    /// reference to the value directly. It is useful to call this
    /// initialiser when utilising values that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the value that this class
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that are
    /// associated with the value.
    init(valueRef: Ref<Value>, errorsRef: ConstRef<[String]>) {
        self.valueRef = valueRef
        self.errorsRef = errorsRef
        self._isValid = { true }
    }

}
