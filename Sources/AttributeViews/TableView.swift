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

public struct TableView<Config: AttributeViewConfig>: View {
    
    //@Binding var value: [[LineAttribute]]
    let label: String
    
    @StateObject var viewModel: TableViewModel<Config>
    
//    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [[LineAttribute]]>, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { root.wrappedValue.modify(attribute: path, value: $0) }
            ),
            viewModel: TableViewModel(root: root, path: path, columns: columns),
            label: label
        )
    }
    
    public init(value: Binding<[[LineAttribute]]>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<[[LineAttribute]], LineAttribute>) -> [String] = { _ in [] }, label: String, columns: [BlockAttributeType.TableColumn]) {
        self.init(
            value: value,
            viewModel: TableViewModel(value: value, errors: errors, subErrors: subErrors, columns: columns),
            label: label
        )
    }
    
    private init(value: Binding<[[LineAttribute]]>, viewModel: TableViewModel<Config>, label: String) {
        //self._value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.pretty.capitalized)
                .font(.headline)
//                .foregroundColor(config.textColor)
            ForEach(viewModel.listErrors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
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
                        TableRowView<Config>(
                            viewModel: row,
                            onDelete: { viewModel.deleteRow(self, row: row.rowIndex) }
                        )
                    }.onMove {
                        viewModel.moveElements(self, atOffsets: $0, to: $1)
                    }.onDelete {
                        viewModel.deleteElements(self, atOffsets: $0)
                    }
                }.frame(minHeight: CGFloat(viewModel.rows.reduce(0) { $0 + ($1.row.first?.underestimatedHeight ?? 5) }) + 75)
                .onExitCommand {
                    viewModel.selection.removeAll(keepingCapacity: true)
                }
                VStack {
                    HStack {
                        ForEach(viewModel.newRow.indices, id: \.self) { index in
                            VStack {
                                LineAttributeView<Config>(
                                    attribute: $viewModel.newRow[index],
                                    errors: Binding(get: { viewModel.errors(self, forRow: viewModel.value.count)[index] }, set: {_ in }),
                                    label: ""
                                )
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                        VStack {
                            Button(action: { viewModel.addElement(self) }, label: {
                                Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                            }).buttonStyle(PlainButtonStyle())
                              .foregroundColor(.blue)
                        }.frame(width: 20)
                    }
                }.padding(.leading, 15).padding(.trailing, 18).padding(.bottom, 15)
            }
        }
    }

}

struct TableView_Previews: PreviewProvider {
    
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
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                columns: [.init(name: "b", type: .bool), .init(name: "i", type: .integer), .init(name: "f", type: .float)]
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [[LineAttribute]] = []
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TableView<DefaultAttributeViewsConfig>(
                value: $value,
                label: "Binding",
                columns: [
                    .init(name: "Bool", type: .bool),
                    .init(name: "Integer", type: .integer),
                    .init(name: "Float", type: .float),
                    .init(name: "Expression", type: .expression(language: .swift)),
                    .init(name: "Enumerated", type: .enumerated(validValues: ["Initial", "Suspend"])),
                    .init(name: "Line", type: .line)
                ]
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
