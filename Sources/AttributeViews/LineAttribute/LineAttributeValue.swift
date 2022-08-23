/*
 * LineAttributeValue.swift
 * LineAttribute
 *
 * Created by Callum McColl on 21/8/22.
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

/// A convenience class for working with a `LineAttribute`.
/// 
/// This class provides functionality for creating and managing the view models
/// associated with a `LineAttribute`. Since a `LineAttribute` can be one of
/// many different types, there exists separate view models for each type. This
/// class therefore makes the task of manging each of these view models trivial.
final class LineAttributeValue: Value<LineAttribute> {

    /// A function that returns a `BoolViewModel` when the attribute associated
    /// with this class is a bool property.
    private let _boolViewModel: () -> BoolViewModel

    /// A function that returns an `IntegerViewModel` when the attribute
    /// associated with this class is an integer property.
    private let _integerViewModel: () -> IntegerViewModel

    /// A function that returns a `FloatViewModel` when the attribute associated
    /// with this class is a float property.
    private let _floatViewModel: () -> FloatViewModel

    /// A function that returns a `ExpressionViewModel` when the attribute
    /// associated with this class is an expression property.
    private let _expressionViewModel: () -> ExpressionViewModel

    /// A function that returns a `EnumeratedViewModel` when the attribute
    /// associated with this class is an enumerated property.
    private let _enumeratedViewModel: () -> EnumeratedViewModel

    /// A function that returns a `LineViewModel` when the attribute
    /// associated with this class is a line property.
    private let _lineViewModel: () -> LineViewModel

    /// A function that returns a `BoolViewModel` when the attribute associated
    /// with this class is a bool property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var boolViewModel: BoolViewModel { _boolViewModel() }

    /// A function that returns an `IntegerViewModel` when the attribute
    /// associated with this class is an integer property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var integerViewModel: IntegerViewModel { _integerViewModel() }

    /// A function that returns a `FloatViewModel` when the attribute associated
    /// with this class is a float property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var floatViewModel: FloatViewModel { _floatViewModel() }

    /// A function that returns a `ExpressionViewModel` when the attribute
    /// associated with this class is an expression property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var expressionViewModel: ExpressionViewModel { _expressionViewModel() }

    /// A function that returns a `EnumeratedViewModel` when the attribute
    /// associated with this class is an enumerated property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var enumeratedViewModel: EnumeratedViewModel { _enumeratedViewModel() }

    /// A function that returns a `LineViewModel` when the attribute
    /// associated with this class is a line property.
    /// 
    /// - Warning: If the attribute associated with this class is not a bool
    /// then this computed property will cause a runtime error.
    var lineViewModel: LineViewModel { _lineViewModel() }

    /// Create a new `LineAttributeValue`.
    /// 
    /// This initialiser create a new `LineAttributeValue` utilising a key path
    /// from a `Modifiable` object that contains the line attribute that this
    /// class is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the line attribute that this class is associated with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the line attribute
    /// from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when presenting the block attribute.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    init<Root: Modifiable>(
        root: Ref<Root>,
        path: Attributes.Path<Root, LineAttribute>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self._boolViewModel = {
            BoolViewModel(root: root, path: path.boolValue, label: label, notifier: notifier)
        }
        self._integerViewModel = {
            IntegerViewModel(root: root, path: path.integerValue, label: label, notifier: notifier)
        }
        self._floatViewModel = {
            FloatViewModel(root: root, path: path.floatValue, label: label, notifier: notifier)
        }
        self._expressionViewModel = {
            ExpressionViewModel(root: root, path: path.expressionValue, label: label, notifier: notifier)
        }
        self._enumeratedViewModel = {
            EnumeratedViewModel(root: root, path: path.enumeratedValue, label: label, notifier: notifier)
        }
        self._lineViewModel = {
            LineViewModel(root: root, path: path.lineValue, label: label, notifier: notifier)
        }
        super.init(root: root, path: path, defaultValue: .bool(false), notifier: notifier)
    }

    /// Create a new `LineAttributeValue`.
    /// 
    /// This initialiser create a new `LineAttributeValue` utilising a
    /// reference to the line attribute directly. It is useful to call this
    /// initialiser when utilising line attributes that do not exist within a
    /// `Modifiable` object.
    /// 
    /// - Parameter valueRef: A reference to the line attribute that this class
    /// is associated with.
    /// 
    /// - Parameter errorsRef: A const-reference to the errors associated with
    /// the line attribute associated with this class.
    /// 
    /// - Parameter label: The label to use when presenting the line attribute.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// line property so that a notification is not sent for every
    /// character change).
    init(
        valueRef: Ref<LineAttribute>,
        errorsRef: ConstRef<[String]>,
        label: String,
        delayEdits: Bool
    ) {
        self._boolViewModel = {
            BoolViewModel(valueRef: valueRef.boolValue, errorsRef: errorsRef, label: label)
        }
        self._integerViewModel = {
            IntegerViewModel(
                valueRef: valueRef.integerValue,
                errorsRef: errorsRef,
                label: label,
                delayEdits: delayEdits
            )
        }
        self._floatViewModel = {
            FloatViewModel(
                valueRef: valueRef.floatValue,
                errorsRef: errorsRef,
                label: label,
                delayEdits: delayEdits
            )
        }
        self._expressionViewModel = {
            ExpressionViewModel(
                valueRef: valueRef.expressionValue,
                errorsRef: errorsRef,
                label: label,
                delayEdits: delayEdits
            )
        }
        self._enumeratedViewModel = {
            EnumeratedViewModel(valueRef: valueRef.enumeratedValue, errorsRef: errorsRef, label: label)
        }
        self._lineViewModel = {
            LineViewModel(
                valueRef: valueRef.lineValue,
                errorsRef: errorsRef,
                label: label,
                delayEdits: delayEdits
            )
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

}
