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

struct TableRowView<Config: AttributeViewConfig>: View {
    
    let subView: (Int) -> AnyView
    @Binding var row: [LineAttribute]
    @Binding var errors: [[String]]
    let onDelete: () -> Void
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, [LineAttribute]>,
        errors: Binding<[[String]]> = .constant([]),
        onDelete: @escaping () -> Void = {}
    ) {
        self.subView = {
            AnyView(LineAttributeView<Config>(root: root, path: path[$0], label: "")
                .frame(minWidth: 0, maxWidth: .infinity))
        }
        self._row = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: { _ = try? root.wrappedValue.modify(attribute: path, value: $0) }
        )
        self._errors = errors
        self.onDelete = onDelete
    }
    
    public init(
        row: Binding<[LineAttribute]>,
        errors: Binding<[[String]]> = .constant([]),
        onDelete: @escaping () -> Void = {}
    ) {
        self.subView = {
            AnyView(LineAttributeView<Config>(attribute: row[$0], errors: errors[$0], label: "")
                .frame(minWidth: 0, maxWidth: .infinity))
        }
        self._row = row
        self._errors = errors
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            ForEach(row.indices, id: \.self) { columnIndex in
                VStack {
                    subView(columnIndex)
                }
            }
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .regular))
                .rotationEffect(.degrees(90))
        }.contextMenu {
            Button("Delete", action: onDelete).keyboardShortcut(.delete)
        }
    }
}

import Machines

struct TableRowView_Previews: PreviewProvider {
    
    struct TableRowViewRoot_Preview: View {
        
        @State var machine: Machine = {
            var machine = Machine.initialSwiftMachine()
            do {
                try machine.addItem(
                    [
                        LineAttribute.enumerated("let", validValues: ["var", "let"]),
                        LineAttribute.line("label"),
                        LineAttribute.expression("Int", language: .swift),
                        LineAttribute.expression("3", language: .swift)
                    ],
                    to: machine
                        .path
                        .attributes[0]
                        .attributes["machine_variables"]
                        .wrappedValue
                        .tableValue
                )
            } catch let e {
                fatalError("\(e)")
            }
            return machine
        }()
        
        let config = DefaultAttributeViewsConfig()
        
        let path = Machine.path
            .attributes[0]
            .attributes["machine_variables"]
            .wrappedValue
            .tableValue[0]
        
        var body: some View {
            TableRowView<DefaultAttributeViewsConfig>(
                root: $machine,
                path: path
            ).environmentObject(config)
        }
        
    }
    
    struct TableRowViewBinding_Preview: View {
        
        @State var value: [LineAttribute] = [
            .bool(false),
            .integer(2),
            .float(3.2),
            .expression("print(\"Hello World!\")", language: .swift),
            .enumerated("Suspend", validValues: ["Initial", "Suspend"]),
            .line("import swiftfsm")
        ]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableRowView<DefaultAttributeViewsConfig>(
                row: $value
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            TableRowViewRoot_Preview()
            TableRowViewBinding_Preview()
        }
    }
}
