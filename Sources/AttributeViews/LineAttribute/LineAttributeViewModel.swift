/*
 * LineAttributeViewModel.swift
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

/// The view model associated with `LineAttributeView`.
/// 
/// This view model is reponsible for managing the state of a
/// `LineAttributeView`. This view model also provides functionality that the
/// `LineAttributeView` requires to function. The `LineAttributeView` displays
/// a `LineAttribute`. Since a `LineAttribute` is an enum, and thus can be
/// one of many different cases, this view model provides access to view models
/// for each separate case.
public final class LineAttributeViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {

    /// A reference to the line attribute that is associated with this view
    /// model.
    private let ref: LineAttributeValue

    /// The `BoolViewModel` when the attribute associated with this view model
    /// is a bool property.
    /// 
    /// - Warning: If the attribute associated with this view model is not a
    /// bool then utilising this property will cause a runtime error.
    lazy var boolViewModel: BoolViewModel = {
        ref.boolViewModel
    }()

    /// The `IntegerViewModel` when the attribute associated with this view
    /// model is an integer property.
    /// 
    /// - Warning: If the attribute associated with this view model is not an
    /// integer then utilising this property will cause a runtime error.
    lazy var integerViewModel: IntegerViewModel = {
        ref.integerViewModel
    }()

    /// The `FloatViewModel` when the attribute associated with this view
    /// model is a float property.
    /// 
    /// - Warning: If the attribute associated with this view model is not a
    /// float then utilising this property will cause a runtime error.
    lazy var floatViewModel: FloatViewModel = {
        ref.floatViewModel
    }()

    /// The `ExpressionViewModel` when the attribute associated with this view
    /// model is an expression property.
    /// 
    /// - Warning: If the attribute associated with this view model is not an
    /// expression then utilising this property will cause a runtime error.
    lazy var expressionViewModel: ExpressionViewModel = {
        ref.expressionViewModel
    }()

    /// The `EnumeratedViewModel` when the attribute associated with this view
    /// model is an enumerated property.
    /// 
    /// - Warning: If the attribute associated with this view model is not an
    /// enumerated property then utilising this property will cause a runtime
    /// error.
    lazy var enumeratedViewModel: EnumeratedViewModel = {
        ref.enumeratedViewModel
    }()

    /// The `LineViewModel` when the attribute associated with this view
    /// model is a line property.
    /// 
    /// - Warning: If the attribute associated with this view model is not a
    /// line then utilising this property will cause a runtime error.
    lazy var lineViewModel: LineViewModel = {
        ref.lineViewModel
    }()

    /// The `LineAttribute` associated with this view model.
    /// 
    /// - Attention: Changing this value triggers an `objectWillChange`
    /// notification to be sent. Depending on the type of the attribute,
    /// an `objectWillChange` notification will also be triggered in the
    /// sub-view-model.
    var lineAttribute: LineAttribute {
        get {
            ref.value
        } set {
            objectWillChange.send()
            ref.value = newValue
            switch newValue.type {
            case .bool:
                boolViewModel.send()
            case .integer:
                integerViewModel.send()
            case .float:
                floatViewModel.send()
            case .expression:
                expressionViewModel.send()
            case .enumerated:
                enumeratedViewModel.send()
            case .line:
                lineViewModel.send()
            }
        }
    }

    /// Create a new `LineAttributeViewModel`.
    /// 
    /// This initialiser create a new `LineAttributeViewModel` utilising a key
    /// path from a `Modifiable` object that contains the line attribute that
    /// this view model is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the line attribute that this view model is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the line attribute
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the line attribute.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, LineAttribute>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.ref = LineAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }

    /// Create a new `LineAttributeViewModel`.
    /// 
    /// This initialiser create a new `LineAttributeViewModel` utilising a
    /// reference to the line attribute directly. It is useful to call this
    /// initialiser when utilising line attributes that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the line attribute that this
    /// view model is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors that are
    /// associated with the line attribute.
    /// 
    /// - Parameter label: The label to use when presenting the line attribute.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// line properties so that a notification is not sent for every
    /// character change).
    public init(
        valueRef: Ref<LineAttribute>,
        errorsRef: ConstRef<[String]>,
        label: String,
        delayEdits: Bool = false
    ) {
        self.ref = LineAttributeValue(
            valueRef: valueRef,
            errorsRef: errorsRef,
            label: label,
            delayEdits: delayEdits
        )
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    public func send() {
        objectWillChange.send()
        if ref.isValid {
            switch ref.value.type {
            case .bool:
                boolViewModel.send()
            case .integer:
                integerViewModel.send()
            case .float:
                floatViewModel.send()
            case .expression:
                expressionViewModel.send()
            case .enumerated:
                enumeratedViewModel.send()
            case .line:
                lineViewModel.send()
            }
        }
    }

}

extension LineAttributeViewModel: Hashable {

    /// Is `lhs` equal to `rhs`.
    /// 
    /// - Parameter lhs: The `LineAttributeViewModel` on the left-hand side
    /// of the equals sign.
    /// 
    /// - Parameter rhs: The `LineAttributeViewModel` on the right-hand side
    /// of the equals sign.
    public static func == (lhs: LineAttributeViewModel, rhs: LineAttributeViewModel) -> Bool {
        lhs.lineAttribute == rhs.lineAttribute
    }

    /// Compute the hash of `self`.
    /// 
    /// - Parameter hasher: The `Hasher` to use to compute the hash.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lineAttribute)
    }

}
