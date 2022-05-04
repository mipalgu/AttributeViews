//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
import Foundation
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

#if canImport(SwiftUI)
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

        var body: some View {
            TableViewPreviewView(
                viewModel: TableViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Root",
                    columns: [.init(name: "b", type: .bool), .init(name: "i", type: .integer), .init(name: "f", type: .float)]
                )
            )
        }

    }

    struct Binding_Preview: View {

        @State var value: [[LineAttribute]] = []

        var body: some View {
            TableViewPreviewView(
                viewModel: TableViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef(copying: []),
                    label: "Binding",
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

    struct TableViewPreviewView: View {

        @StateObject var viewModel: TableViewModel

        var body: some View {
            TableView(viewModel: viewModel)
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
