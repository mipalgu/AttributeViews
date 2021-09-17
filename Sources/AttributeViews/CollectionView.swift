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

public struct CollectionView: View {
    
    @ObservedObject var viewModel: CollectionViewModel
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.label.pretty.capitalized)
                .font(.headline)
            ForEach(viewModel.listErrors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
                CollectionBodyView(viewModel: viewModel.collectionBodyViewModel)
                NewAttributeView(viewModel: viewModel.newRowViewModel)
            }
        }
    }
    
}

struct CollectionBodyView: View {
    
    @ObservedObject var viewModel: CollectionBodyViewModel
    
    var body: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.rows, id: \.id) { row in
                CollectionRowView(
                    viewModel: row,
                    onDelete: { viewModel.deleteRow(row: row.rowIndex) }
                )
            }.onMove {
                viewModel.moveElements(atOffsets: $0, to: $1)
            }.onDelete {
                viewModel.deleteElements(atOffsets: $0)
            }
        }.frame(minHeight: CGFloat(viewModel.rows.reduce(0) { $0 + $1.row.underestimatedHeight }) + 75)
        .onExitCommand {
            viewModel.selection.removeAll(keepingCapacity: true)
        }
    }
    
}

struct NewAttributeView: View {

    @ObservedObject var viewModel: NewAttributeViewModel

    //@EnvironmentObject var config: Config

    var body: some View {
        VStack {
            HStack {
                if viewModel.newRow.attribute.isLine {
                    AttributeView(viewModel: viewModel.newRow)
                }
                VStack {
                    Button(action: viewModel.addElement, label: {
                        Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                    }).buttonStyle(PlainButtonStyle())
                      .foregroundColor(.blue)
                }.frame(width: 20)
            }
        }.padding(.leading, 15).padding(.trailing, 18).padding(.bottom, 15)
    }

}

#if canImport(SwiftUI)
struct CollectionView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "lines",
                        type: .collection(type: .line)
                    )
                ],
                attributes: [
                    "lines": .collection(lines: ["Hello", "World"])
                ],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["lines"].wrappedValue.collectionValue
        
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Root",
                    type: .line
                )
            )
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [Attribute] = []
        
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef(copying: []),
                    label: "Binding",
                    type: .bool,
                    delayEdits: false
                )
            )
        }
        
    }
    
    struct CollectionViewPreviewView: View {
        
        @StateObject var viewModel: CollectionViewModel
        
        var body: some View {
            CollectionView(viewModel: viewModel)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
#endif
