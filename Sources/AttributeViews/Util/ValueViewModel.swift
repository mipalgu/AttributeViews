/*
 * ValueViewModel.swift
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

/// A generic view model for working with values that have associated errors.
/// 
/// Generally, when working with attributes that are not recursive, you will
/// want to use this view model to tie a value to a set of errors. This view
/// model allows one to make changes to a value and automatically generate
/// errors for the value utilising a `Modifiable` object.
public final class ValueViewModel<T>: ObservableObject, GlobalChangeNotifier {

    /// A reference to the value associated with this view model.
    private let ref: Value<T>

    /// The label of the value.
    public let label: String

    /// The errors associated with `value`.
    var errors: [String] {
        ref.errors
    }

    /// The value associated with this view model.
    /// 
    /// - Attention: Changing this value will cause an `objectWillChange`
    /// notification to be sent.
    var value: T {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
        }
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the value
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// value if the value ceases to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the value is
    /// deleted.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T>,
        defaultValue: T,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = Value(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
        self.label = label
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to an optional
    /// containing the value from the base `Modifiable` object.
    /// 
    /// - Parameter defaultValue: The defalut value to use for the
    /// value if the value ceases to exist. This is necessary to
    /// prevent `SwiftUi` crashes during animations when the value is
    /// deleted.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T?>,
        defaultValue: T,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = Value(root: root, path: path, defaultValue: defaultValue, notifier: notifier)
        self.label = label
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the value
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByStringLiteral {
        self.init(root: root, path: path, defaultValue: "", label: label, notifier: notifier)
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the value
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByIntegerLiteral {
        self.init(root: root, path: path, defaultValue: 0, label: label, notifier: notifier)
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the value
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByBooleanLiteral {
        self.init(root: root, path: path, defaultValue: false, label: label, notifier: notifier)
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to an optional
    /// containing the value from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T?>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByStringLiteral {
        self.init(root: root, path: path, defaultValue: "", label: label, notifier: notifier)
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to an optional
    /// containing the value from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T?>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByIntegerLiteral {
        self.init(root: root, path: path, defaultValue: 0, label: label, notifier: notifier)
    }

    /// Create a new `ValueViewModel`.
    /// 
    /// This initialiser create a new `ValueViewModel` utilising a key path
    /// from a `Modifiable` object that contains the value that this
    /// view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the value that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to an optional
    /// containing the value from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public convenience init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, T?>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) where T: ExpressibleByBooleanLiteral {
        self.init(root: root, path: path, defaultValue: false, label: label, notifier: notifier)
    }

    /// Create a new `Value`.
    /// 
    /// This initialiser create a new `Value` utilising a
    /// reference to the value directly. It is useful to call this
    /// initialiser when utilising values that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the value that this view model
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that are
    /// associated with the value.
    /// 
    /// - Parameter label: The label to use when presenting the value.
    public init(valueRef: Ref<T>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), label: String) {
        self.ref = Value(valueRef: valueRef, errorsRef: errorsRef)
        self.label = label
    }

    /// Manually trigger an `objectWillChange` notification.
    public func send() {
        objectWillChange.send()
    }

}
