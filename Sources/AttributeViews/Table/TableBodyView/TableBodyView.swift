/*
 * TableBodyView.swift
 * 
 *
 * Created by Callum McColl on 4/5/2022.
 * Copyright © 2022 Callum McColl. All rights reserved.
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
import Foundation
#else
import SwiftUI
#endif

import Attributes
import GUUI

struct TableBodyView: View {

    @ObservedObject var viewModel: TableBodyViewModel

    var body: some View {
        List(selection: $viewModel.selection) {
            VStack {
                HStack {
                    ForEach(viewModel.columns, id: \.name) { column in
                        Text(column.name.pretty)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    Spacer().frame(width: 20)
                }
            }
            ForEach(viewModel.rows, id: \.id) { row in
                TableRowView(
                    viewModel: row,
                    onDelete: { viewModel.deleteRow(row: row.rowIndex) }
                )
            }.onMove {
                viewModel.moveElements(atOffsets: $0, to: $1)
            }.onDelete {
                viewModel.deleteElements(atOffsets: $0)
            }
        }.frame(minHeight: CGFloat(viewModel.rows.reduce(0) { $0 + ($1.row.first?.underestimatedHeight ?? 5) }) + 75)
        .onExitCommand {
            viewModel.selection.removeAll(keepingCapacity: true)
        }
    }

}

#if canImport(SwiftUI)
struct TableBodyView_Previews: PreviewProvider {

    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "table",
                        type: .table(columns: [("b", .bool), ("i", .integer), ("f", .float)])
                    )
                ],
                attributes: [
                    "table": .table([
                        [.bool(false), .integer(1), .float(1.1)],
                        [.bool(true), .integer(2), .float(2.2)]
                    ], columns: [("b", .bool), ("i", .integer), ("f", .float)]
                    )
                ],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["table"].wrappedValue.tableValue
        
        var body: some View {
            TableBodyViewPreviewView(
                viewModel: TableBodyViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    columns: [.init(name: "b", type: .bool), .init(name: "i", type: .integer), .init(name: "f", type: .float)]
                )
            )
        }
        
    }

    struct Binding_Preview: View {
        
        @State var value: [[LineAttribute]] = []
        
        var body: some View {
            TableBodyViewPreviewView(
                viewModel: TableBodyViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef(copying: []),
                    columns: [
                        .init(name: "Bool", type: .bool),
                        .init(name: "Integer", type: .integer),
                        .init(name: "Float", type: .float),
                        .init(name: "Expression", type: .expression(language: .swift)),
                        .init(name: "Enumerated", type: .enumerated(validValues: ["Initial", "Suspend"])),
                        .init(name: "Line", type: .line)
                    ],
                    delayEdits: false
                )
            )
        }
        
    }

    struct TableBodyViewPreviewView: View {
        
        @StateObject var viewModel: TableBodyViewModel
        
        var body: some View {
            TableBodyView(viewModel: viewModel)
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
