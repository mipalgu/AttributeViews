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
import GUUI

public struct CollectionView<Config: AttributeViewConfig>: View, ListViewProtocol {
    
    @Binding var value: [Row<Attribute>]
    @Binding var errors: [String]
    let display: ReadOnlyPath<Attribute, LineAttribute>?
    let label: String
    let type: AttributeType
    
    private let viewModel: CollectionViewViewModel<Config>
    
    @State var selection: Set<Int> = []
    @State var editing: Int? = nil
    @State var newRow: Attribute
    
    //@EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [Attribute]>, display: ReadOnlyPath<Attribute, LineAttribute>? = nil, label: String, type: AttributeType, expanded: Binding<[AnyKeyPath: Bool]>? = nil) {
        self.init(
            value: Binding(
                get: {
                    path.isNil(root.wrappedValue) ? [] : root.wrappedValue[keyPath: path.keyPath]
                },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            display: display,
            label: label,
            type: type,
            viewModel: CollectionViewViewModel(
                CollectionViewKeyPathViewModel(
                    root: root,
                    path: path,
                    type: type,
                    expanded: expanded
                )
            )
        )
    }
    
    init(value: Binding<[Attribute]>, errors: Binding<[String]> = .constant([]), display: ReadOnlyPath<Attribute, LineAttribute>? = nil, label: String, type: AttributeType) {
        self.init(
            value: value,
            errors: errors,
            display: display,
            label: label,
            type: type,
            viewModel: CollectionViewViewModel(
                CollectionViewBindingViewModel(
                    value: value,
                    errors: errors,
                    type: type
                )
            )
        )
    }
    
    private init(value: Binding<[Attribute]>, errors: Binding<[String]>, display: ReadOnlyPath<Attribute, LineAttribute>?, label: String, type: AttributeType, viewModel: CollectionViewViewModel<Config>) {
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
        self.display = display
        self.label = label
        self.type = type
        self.viewModel = viewModel
        self._newRow = State(initialValue: viewModel.newRow)
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
                    if let editingIndex = editing {
                        HStack {
                            Spacer()
                            Button(action: {
                                if editingIndex == value.count {
                                    viewModel.addElement(self)
                                }
                                editing = nil
                            }, label: {
                                Image(systemName: "square.and.pencil").font(.system(size: 16, weight: .regular))
                            }).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                            Divider()
                            Button(action: {
                                editing = nil
                            }, label: {
                                Image(systemName: "trash").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.red)
                        }
                        if editingIndex >= value.count {
                            AttributeView<Config>(attribute: $newRow, label: "")
                        } else {
                            viewModel.rowView(self, forRow: editingIndex)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: { editing = value.count }, label: {
                                Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                            }).animation(.easeOut).buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                        }
                    }
                }
            }.padding(.bottom, 5)
            Divider()
            if !value.isEmpty && ((editing == nil && type.isBlock == true) || type.isLine) {
                List(selection: $selection) {
                    ForEach(value.indices, id: \.self) { index in
                        HStack(spacing: 1) {
                            switch type {
                            case .line:
                                viewModel.rowView(self, forRow: index)
                                Spacer()
                            case .block:
                                if let display = display {
                                    Text(value[index].data[keyPath: display.keyPath].strValue)
                                } else {
                                    Text(value[index].data.strValue ?? "\(index)")
                                }
                                Spacer()
                                Button(action: { editing = index }, label: { Image(systemName: "pencil").font(.system(size: 16, weight: .regular)) })
                                    .buttonStyle(PlainButtonStyle())
                            }
                            Image(systemName: "ellipsis").font(.system(size: 16, weight: .regular)).rotationEffect(.degrees(90))
                        }.contextMenu {
                            Button("Delete") {
                                viewModel.deleteRow(self, row: index)
                            }.keyboardShortcut(.delete)
                        }
                    }.onMove {
                        viewModel.moveElements(self, atOffsets: $0, to: $1)
                    }.onDelete {
                        viewModel.deleteElements(self, atOffsets: $0)
                    }
                    
                }.frame(minHeight: max(CGFloat(value.reduce(0) { $0 + $1.data.underestimatedHeight }), 100))
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
    let expanded: Binding<[AnyKeyPath: Bool]>?
    
    var newRow: Attribute {
        type.defaultValue
    }
    
    init(root: Binding<Root>, path: Attributes.Path<Root, [Attribute]>, type: AttributeType, expanded: Binding<[AnyKeyPath: Bool]>? = nil) {
        self.root = root
        self.path = path
        self.type = type
        self.expanded = expanded
    }
    
    func errors(_ view: CollectionView<Config>, forRow row: Int) -> [String] {
        return root.wrappedValue.errorBag.errors(includingDescendantsForPath: path[row]).map(\.message)
    }
    
    func rowView(_ view: CollectionView<Config>, forRow row: Int) -> AttributeView<Config> {
        return AttributeView(root: root, path: path[row], label: "", expanded: expanded)
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
