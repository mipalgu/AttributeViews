//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

public struct TableView: View {
    
    @ObservedObject var viewModel: TableViewModel
    
    public init(viewModel: TableViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.label.pretty.capitalized)
                .font(.headline)
            ForEach(viewModel.listErrors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
                TableBodyView(viewModel: viewModel.tableBodyViewModel)
                NewRowView(viewModel: viewModel.newRowViewModel)
            }
        }
    }

}

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

struct NewRowView: View {
    
    @ObservedObject var viewModel: NewRowViewModel
    
    //@EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<viewModel.newRow.count) { index in
                    VStack {
                        LineAttributeView(viewModel: viewModel.newRow[index])
                    }.frame(minWidth: 0, maxWidth: .infinity)
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

//struct TableView_Previews: PreviewProvider {
//    
//    struct Root_Preview: View {
//        
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields",
//                fields: [
//                    Field(
//                        name: "table",
//                        type: .table(columns: [("b", .bool), ("i", .integer), ("f", .float)])
//                    )
//                ],
//                attributes: [
//                    "table": .table([
//                        [.bool(false), .integer(1), .float(1.1)],
//                        [.bool(true), .integer(2), .float(2.2)]
//                    ], columns: [("b", .bool), ("i", .integer), ("f", .float)]
//                    )
//                ],
//                metaData: [:]
//            )
//        ])
//        
//        let path = EmptyModifiable.path.attributes[0].attributes["table"].wrappedValue.tableValue
//        
//        var body: some View {
//            TableView(
//                root: $modifiable,
//                path: path,
//                label: "Root",
//                columns: [.init(name: "b", type: .bool), .init(name: "i", type: .integer), .init(name: "f", type: .float)]
//            )
//        }
//        
//    }
//    
//    struct Binding_Preview: View {
//        
//        @State var value: [[LineAttribute]] = []
//        
//        var body: some View {
//            TableView(
//                value: $value,
//                label: "Binding",
//                columns: [
//                    .init(name: "Bool", type: .bool),
//                    .init(name: "Integer", type: .integer),
//                    .init(name: "Float", type: .float),
//                    .init(name: "Expression", type: .expression(language: .swift)),
//                    .init(name: "Enumerated", type: .enumerated(validValues: ["Initial", "Suspend"])),
//                    .init(name: "Line", type: .line)
//                ]
//            )
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Root_Preview()
//            Binding_Preview()
//        }
//    }
//}
