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

final class AttributeViewModel: ObservableObject {
    
    let value: Binding<Attribute>
    
    var attribute: Attribute {
        get {
            value.wrappedValue
        } set {
            value.wrappedValue = newValue
            objectWillChange.send()
        }
    }
    
    var blockAttribute: BlockAttribute {
        get {
            value.wrappedValue.blockAttribute
        } set {
            value.wrappedValue.blockAttribute = newValue
            objectWillChange.send()
        }
    }
    
    var lineAttribute: LineAttribute {
        get {
            value.wrappedValue.lineAttribute
        } set {
            value.wrappedValue.lineAttribute = newValue
            objectWillChange.send()
        }
    }
    
    init(value: Binding<Attribute>) {
        self.value = value
    }
    
}

final class LineAttributeViewModel: ObservableObject, Identifiable {
    
    let value: Binding<LineAttribute>
    
    var lineAttribute: LineAttribute {
        get {
            value.wrappedValue
        } set {
            value.wrappedValue = newValue
            objectWillChange.send()
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
            value.wrappedValue.boolValue
        } set {
            value.wrappedValue.boolValue = newValue
            objectWillChange.send()
        }
    }
    
    var integerValue: Int {
        get {
            value.wrappedValue.integerValue
        } set {
            value.wrappedValue.integerValue = newValue
            objectWillChange.send()
        }
    }
    
    var floatValue: Double {
        get {
            value.wrappedValue.floatValue
        } set {
            value.wrappedValue.floatValue = newValue
        }
    }
    
    var expressionValue: Expression {
        get {
            value.wrappedValue.expressionValue
        } set {
            value.wrappedValue.expressionValue = newValue
            objectWillChange.send()
        }
    }
    
    var enumeratedValue: String {
        get {
            value.wrappedValue.enumeratedValue
        } set {
            value.wrappedValue.enumeratedValue = newValue
            objectWillChange.send()
        }
    }
    
    var lineValue: String {
        get {
            value.wrappedValue.lineValue
        } set {
            value.wrappedValue.lineValue = newValue
            objectWillChange.send()
        }
    }
    
    init(value: Binding<LineAttribute>) {
        self.value = value
    }
    
}

extension LineAttributeViewModel: Hashable {
    
    static func ==(lhs: LineAttributeViewModel, rhs: LineAttributeViewModel) -> Bool {
        lhs.lineAttribute == rhs.lineAttribute
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(lineAttribute)
    }
    
}
