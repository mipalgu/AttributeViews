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

fileprivate final class LineAttributeValue: Value<LineAttribute> {

    private let _boolViewModel: () -> BoolViewModel

    private let _integerViewModel: () -> IntegerViewModel

    private let _floatViewModel: () -> FloatViewModel

    private let _expressionViewModel: () -> ExpressionViewModel

    private let _enumeratedViewModel: () -> EnumeratedViewModel

    private let _lineViewModel: () -> LineViewModel

    var boolViewModel: BoolViewModel { _boolViewModel() }

    var integerViewModel: IntegerViewModel { _integerViewModel() }

    var floatViewModel: FloatViewModel { _floatViewModel() }

    var expressionViewModel: ExpressionViewModel { _expressionViewModel() }

    var enumeratedViewModel: EnumeratedViewModel { _enumeratedViewModel() }

    var lineViewModel: LineViewModel { _lineViewModel() }

    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, LineAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
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

    init(valueRef: Ref<LineAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool) {
        self._boolViewModel = {
            BoolViewModel(valueRef: valueRef.boolValue, errorsRef: errorsRef, label: label)
        }
        self._integerViewModel = {
            IntegerViewModel(valueRef: valueRef.integerValue, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
        }
        self._floatViewModel = {
            FloatViewModel(valueRef: valueRef.floatValue, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
        }
        self._expressionViewModel = {
            ExpressionViewModel(valueRef: valueRef.expressionValue, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
        }
        self._enumeratedViewModel = {
            EnumeratedViewModel(valueRef: valueRef.enumeratedValue, errorsRef: errorsRef, label: label)
        }
        self._lineViewModel = {
            LineViewModel(valueRef: valueRef.lineValue, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
        }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }

}

public final class LineAttributeViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {

    private let ref: LineAttributeValue

    lazy var boolViewModel: BoolViewModel = {
        ref.boolViewModel
    }()

    lazy var integerViewModel: IntegerViewModel = {
        ref.integerViewModel
    }()

    lazy var floatViewModel: FloatViewModel = {
        ref.floatViewModel
    }()

    lazy var expressionViewModel: ExpressionViewModel = {
        ref.expressionViewModel
    }()

    lazy var enumeratedViewModel: EnumeratedViewModel = {
        ref.enumeratedViewModel
    }()

    lazy var lineViewModel: LineViewModel = {
        ref.lineViewModel
    }()

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

    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, LineAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.ref = LineAttributeValue(root: root, path: path, label: label, notifier: notifier)
    }

    public init(valueRef: Ref<LineAttribute>, errorsRef: ConstRef<[String]>, label: String, delayEdits: Bool = false) {
        self.ref = LineAttributeValue(valueRef: valueRef, errorsRef: errorsRef, label: label, delayEdits: delayEdits)
    }

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

    public static func ==(lhs: LineAttributeViewModel, rhs: LineAttributeViewModel) -> Bool {
        lhs.lineAttribute == rhs.lineAttribute
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(lineAttribute)
    }

}
