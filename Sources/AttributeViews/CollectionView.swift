/*
 * CollectionView.swift
 * MachineViews
 *
 * Created by Callum McColl on 16/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

public struct CollectionView<Root: Modifiable>: View {
    
    struct CollectionElement: Hashable, Identifiable {
        
        var id: Int {
            self.attribute.id
        }
        
        var attribute: Attribute
        
        var subView: () -> AttributeView<Root>
        
        static func ==(lhs: CollectionElement, rhs: CollectionElement) -> Bool {
            return lhs.attribute == rhs.attribute
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(attribute)
        }
        
    }
    
    @Binding var root: Root
    @Binding var value: [CollectionElement]
    @State var errors: [String]
    let label: String
    let type: AttributeType
    
    @State var newAttribute: Attribute
    
    @State var selection: Set<Int>
    
    @EnvironmentObject var config: Config
    
    @State var creating: Bool = false
    
    let addElement: () -> Void
    let deleteElement: (CollectionElement) -> Void
    let deleteElements: (IndexSet) -> Void
    let moveElements: (IndexSet, Int) -> Void
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, [Attribute]>, label: String, type: AttributeType) {
        self._root = root
        let errors = State<[String]>(initialValue: root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message })
        self._value = Binding(
            get: {
                root.wrappedValue[keyPath: path.keyPath].enumerated().map { (index, element) in
                    CollectionElement(attribute: element, subView: { AttributeView(root: root, path: path[index], label: "") })
                }
            },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0.map { $0.attribute })
                errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
            }
        )
        self._errors = errors
        self.label = label
        self.type = type
        let newAttribute = State<Attribute>(initialValue: type.defaultValue)
        self._newAttribute = newAttribute
        let selection = State<Set<Int>>(initialValue: [])
        self._selection = selection
        self.addElement = {
            if let _ = try? root.wrappedValue.addItem(newAttribute.wrappedValue, to: path) {
                newAttribute.wrappedValue = type.defaultValue
            }
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message)
        }
        let deleteOffsets: (IndexSet) -> Void = { (offsets) in
            try? root.wrappedValue.deleteItems(table: path, items: offsets)
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message)
        }
        self.deleteElement = { (element) in
            guard let index = root.wrappedValue[keyPath: path.keyPath].firstIndex(of: element.attribute) else {
                return
            }
            let offsets: IndexSet = selection.wrappedValue.contains(element.id)
                ? IndexSet(root.wrappedValue[keyPath: path.keyPath].enumerated().lazy.filter { selection.wrappedValue.contains($1.id) }.map { $0.0 })
                : [index]
            deleteOffsets(offsets)
        }
        self.deleteElements = deleteOffsets
        self.moveElements = { (source, destination) in
            try? root.wrappedValue.moveItems(table: path, from: source, to: destination)
            errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message)
        }
    }
    
    init(root: Binding<Root>, value: Binding<[Attribute]>, label: String, type: AttributeType) {
        self._root = root
        self._value = Binding(
            get: {
                value.wrappedValue.enumerated().map { (index, element) in
                    CollectionElement(attribute: element, subView: { AttributeView(root: root, attribute: value[index], label: "") })
                }
            },
            set: {
                value.wrappedValue = $0.map { $0.attribute }
            }
        )
        self._errors = State(initialValue: [])
        self.label = label
        self.type = type
        let newAttribute = State<Attribute>(initialValue: type.defaultValue)
        self._newAttribute = newAttribute
        let selection = State<Set<Int>>(initialValue: [])
        self._selection = selection
        self.addElement = {
            value.wrappedValue.append(newAttribute.wrappedValue)
            newAttribute.wrappedValue = type.defaultValue
        }
        let deleteOffsets: (IndexSet) -> Void = { (offsets) in
            value.wrappedValue.remove(atOffsets: offsets)
        }
        self.deleteElement = { (element) in
            guard let index = value.wrappedValue.firstIndex(of: element.attribute) else {
                return
            }
            let offsets: IndexSet = selection.wrappedValue.contains(element.id)
                ? IndexSet(value.wrappedValue.enumerated().lazy.filter { selection.wrappedValue.contains($1.id) }.map { $0.0 })
                : [index]
            deleteOffsets(offsets)
        }
        self.deleteElements = deleteOffsets
        self.moveElements = { (source, destination) in
            value.wrappedValue.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VStack {
                switch type {
                case .line:
                    HStack {
                        Text(label.pretty + ":").fontWeight(.bold)
                        AttributeView(root: $root, attribute: $newAttribute, label: "New " + label)
                        Button(action: addElement, label: {
                            Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                        }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    }
                case .block:
                    if creating {
                        HStack {
                            Text(label + ":").fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                addElement()
                                creating = false
                            }, label: {
                                Image(systemName: "square.and.pencil").font(.system(size: 16, weight: .regular))
                            }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                            Divider()
                            Button(action: {
                                creating = false
                            }, label: {
                                Image(systemName: "trash").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.red)
                        }
                        AttributeView(root: $root, attribute: $newAttribute, label: "")
                    } else {
                        HStack {
                            Text(label + ":").fontWeight(.bold)
                            Spacer()
                            Button(action: { creating = true }, label: {
                                Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                        }
                    }
                }
            }.padding(.bottom, 5)
            Divider()
            if !value.isEmpty {
                List(selection: $selection) {
                    ForEach(value, id: \.self) { element in
                        HStack(spacing: 1) {
                            element.subView()
                            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                        }.contextMenu {
                            Button("Delete", action: { deleteElement(element) }).keyboardShortcut(.delete)
                        }
                    }.onMove(perform: moveElements).onDelete(perform: deleteElements)
                }.frame(minHeight: min(CGFloat(value.count * (type == .line ? 30 : 80) + 15), 100))
            }
        }.padding(.top, 2)
    }
}
