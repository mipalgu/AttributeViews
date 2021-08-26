/*
 * TableRowView.swift
 * 
 *
 * Created by Callum McColl on 21/3/21.
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

final class TableRowViewModel: ObservableObject, Identifiable, GlobalChangeNotifier {
    
    private let table: Ref<[[LineAttribute]]>
    
    @Published var rowIndex: Int
    
    @Published var redraw: Int = 0
    
    private var viewModels: [Int: LineAttributeViewModel] = [:]
    
    private let lineAttributeViewModel: (Int, Int) -> LineAttributeViewModel
    
    var row: [LineAttribute] {
        rowIndex >= table.value.count ? [] : table.value[rowIndex]
    }
    
    init(table: Ref<[[LineAttribute]]>, rowIndex: Int, lineAttributeViewModel: @escaping (Int, Int) -> LineAttributeViewModel) {
        self.table = table
        self.rowIndex = rowIndex
        self.lineAttributeViewModel = lineAttributeViewModel
    }
    
    func view(atIndex index: Int) -> AnyView {
        guard rowIndex < table.value.count && index < table.value[rowIndex].count else {
            return AnyView(EmptyView())
        }
        if let viewModel = viewModels[index] {
            return AnyView(LineAttributeView(viewModel: viewModel))
        }
        let viewModel = self.lineAttributeViewModel(rowIndex, index)
        viewModels[index] = viewModel
        return AnyView(LineAttributeView(viewModel: viewModel))
    }
    
    func send() {
        objectWillChange.send()
        viewModels = [:]
    }
    
}

struct TableRowView: View {
    
    @ObservedObject var viewModel: TableRowViewModel
    let onDelete: () -> Void
    
    init(viewModel: TableRowViewModel, onDelete: @escaping () -> Void = {}) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            ForEach(viewModel.row.indices, id: \.self) { index in
                VStack {
                    viewModel.view(atIndex: index).frame(minWidth: 0, maxWidth: .infinity)
                }
            }
            VStack {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .regular))
                    .rotationEffect(.degrees(90))
            }.frame(width: 20)
        }.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }
    }
}

#if canImport(SwiftUI)
struct TableRowView_Previews: PreviewProvider {
    
//    struct Root_Preview: View {
//
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [
//                    Field(
//                        name: "table",
//                        type: .table(columns: [
//                            ("bool", .bool),
//                            ("int", .integer),
//                            ("float", .float),
//                            ("enum", .enumerated(validValues: ["a", "b", "c"])),
//                            ("line", .line)
//                        ])
//                    )
//                ],
//                attributes: [
//                    "table": .table([
//                        [.bool(false), .integer(1), .float(1.1), .enumerated("a", validValues: ["a", "b", "c"]), .line("hello")]
//                    ], columns: [
//                        ("bool", .bool),
//                        ("int", .integer),
//                        ("float", .float),
//                        ("enum", .enumerated(validValues: ["a", "b", "c"])),
//                        ("line", .line)
//                    ])
//                ],
//                metaData: [:]
//            )
//        ])
//
//        let path = EmptyModifiable.path.attributes[0].attributes["table"].wrappedValue.tableValue[0]
//
//        let config = DefaultAttributeViewsConfig()
//
//        var body: some View {
//            TableRowView<DefaultAttributeViewsConfig>(
//                root: $modifiable,
//                path: path
//            ).environmentObject(config)
//        }
//
//    }
    
    struct Binding_Preview: View {
        
        @State var value: [[LineAttribute]] = [[.bool(false), .integer(1), .float(1.1), .enumerated("a", validValues: ["a", "b", "c"]), .line("hello")]]
        
        @State var errors: [[String]] = [
            ["bool error1", "bool error2"],
            ["int error"],
            ["float error1", "float error2", "float error3"],
            [],
            ["Really long line error that is very long in length"]
        ]
        
        var body: some View {
            TableRowPreviewView(
                viewModel: TableRowViewModel(
                    table: Ref(get: { self.value }, set: { self.value = $0 }),
                    rowIndex: 0,
                    lineAttributeViewModel: { (row, col) in
                        LineAttributeViewModel(
                            valueRef: Ref(get: { self.value[row][col] }, set: { self.value[row][col] = $0 }),
                            errorsRef: ConstRef(copying: []),
                            label: ""
                        )
                    }
                )
            )
        }
        
    }
    
    struct TableRowPreviewView: View {
        
        @StateObject var viewModel: TableRowViewModel
        
        var body: some View {
            TableRowView(viewModel: viewModel)
        }
        
    }
    
    static var previews: some View {
        VStack {
//            Root_Preview()
//            Spacer()
//            Divider()
//            Spacer()
            Binding_Preview()
        }
    }
}
#endif
