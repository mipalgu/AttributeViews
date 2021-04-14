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

public struct CollectionView<Config: AttributeViewConfig>: View, ListViewProtocol {
    
    
    @Binding var value: [Row<Attribute>]
    @Binding var errors: [String]
    let label: String
    let type: AttributeType
    
    private let viewModel: CollectionViewViewModel<Config>
    
    @State var selection: Set<Row<Attribute>> = []
    @State var creating: Bool = false
    @State var newRow: Attribute
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [Attribute]>, label: String, type: AttributeType) {
        var idCache = IDCache<Attribute>()
        self._value = Binding(
            get: {
                root.wrappedValue[keyPath: path.keyPath].enumerated().map { (index, row) in
                    Row(id: idCache.id(for: row), index: index, data: row)
                }
            },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0.map(\.data))
            }
        )
        self._errors = Binding(
            get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
            set: { _ in }
        )
        self.label = label
        self.type = type
        self._newRow = State(initialValue: type.defaultValue)
        self.viewModel = AnyListViewModel(CollectionViewKeyPathViewModel<Config, Root>(root: root, path: path, type: type))
    }
    
    init(value: Binding<[Attribute]>, errors: Binding<[String]> = .constant([]), label: String, type: AttributeType) {
        var idCache = IDCache<Attribute>()
        self._value = Binding(
            get: {
                value.wrappedValue.enumerated().map { (index, row) in
                    Row(id: idCache.id(for: row), index: index, data: row)
                }
            },
            set: {
                value.wrappedValue = $0.map(\.data)
            }
        )
        self._errors = errors
        self.label = label
        self.type = type
        self._newRow = State(initialValue: type.defaultValue)
        self.viewModel = AnyListViewModel(CollectionViewBindingViewModel<Config>(value: value, errors: errors, type: type))
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text(label.pretty).font(.headline)
                switch type {
                case .line:
                    HStack {
                        AttributeView<Config>(attribute: $newRow, label: "New " + label)
                        Button(action: {
                            viewModel.addElement(self)
                        }, label: {
                            Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                        }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    }
                case .block:
                    if creating {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.addElement(self)
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
                        AttributeView<Config>(attribute: $newRow, label: "")
                    } else {
                        HStack {
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
                            viewModel.rowView(self, forRow: element.index)
                            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                        }.contextMenu {
                            Button("Delete") {
                                viewModel.deleteRow(self, row: element.index)
                            }.keyboardShortcut(.delete)
                        }
                    }.onMove {
                        viewModel.moveElements(self, atOffsets: $0, to: $1)
                    }.onDelete {
                        viewModel.deleteElements(self, atOffsets: $0)
                    }
                }.frame(minHeight: min(CGFloat(value.count * (type == .line ? 30 : 80) + 15), 100))
            }
        }.padding(.top, 2)
    }
}

struct CollectionView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "collection", type: .collection(type: .integer))], attributes: ["collection": .collection(integers: [1, 2, 3, 4, 5])], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["collection"].wrappedValue.collectionValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            CollectionView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                type: .integer
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [Attribute] = [1, 2, 3, 4, 5].map { Attribute.integer($0) }
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            CollectionView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding", type: .integer).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}

fileprivate typealias CollectionViewViewModel<Config: AttributeViewConfig> = AnyListViewModel<CollectionView<Config>, Attribute, AttributeView<Config>, String>

fileprivate struct CollectionViewKeyPathViewModel<Config: AttributeViewConfig, Root: Modifiable>: ListViewModelProtocol, RootPathContainer {
    
    let root: Binding<Root>
    let path: Attributes.Path<Root, [Attribute]>
    let type: AttributeType
    
    var newRow: Attribute {
        type.defaultValue
    }
    
    init(root: Binding<Root>, path: Attributes.Path<Root, [Attribute]>, type: AttributeType) {
        self.root = root
        self.path = path
        self.type = type
    }
    
    func errors(_ view: CollectionView<Config>, forRow row: Int) -> [String] {
        return root.wrappedValue.errorBag.errors(includingDescendantsForPath: path[row]).map(\.message)
    }
    
    func rowView(_ view: CollectionView<Config>, forRow row: Int) -> AttributeView<Config> {
        return AttributeView(root: root, path: path[row], label: "")
    }
    
    
    
}

fileprivate struct CollectionViewBindingViewModel<Config: AttributeViewConfig>: ListViewModelProtocol, ValueErrorsContainer {
    
    let value: Binding<[Attribute]>
    let errors: Binding<[String]>
    let type: AttributeType
    
    var newRow: Attribute {
        type.defaultValue
    }
    
    init(value: Binding<[Attribute]>, errors: Binding<[String]>, type: AttributeType) {
        self.value = value
        self.errors = errors
        self.type = type
    }
    
    func errors(_ view: CollectionView<Config>, forRow _: Int) -> [String] {
        return []
    }
    
    func rowView(_ view: CollectionView<Config>, forRow row: Int) -> AttributeView<Config> {
        return AttributeView(attribute: value[row], label: "")
    }
    
}
