//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import Foundation
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

// swiftlint:disable type_contents_order

/// A view that displays a table of attributes.
/// 
/// The table contains a header and a body. The header contains the
/// title of the table with the errors vertically stacked below the title.
/// The body contains vertically stacked rows with contents of the table.
/// At the bottom of the table are input fields for adding a new row.
public struct TableView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: TableViewModel

    /// Create a new `TableView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: TableViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
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

/// The previews of associated with `TableView`.
struct TableView_Previews: PreviewProvider {

    /// A view that renders a `TableView` preview containing
    /// a table that exist within a `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object containing the table.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "table",
                        type: .table(columns: [("b", .bool), ("i", .integer), ("f", .float)])
                    )
                ],
                attributes: [
                    "table": .table(
                        [
                            [.bool(false), .integer(1), .float(1.1)],
                            [.bool(true), .integer(2), .float(2.2)]
                        ],
                        columns: [("b", .bool), ("i", .integer), ("f", .float)]
                    )
                ],
                metaData: [:]
            )
        ])

        /// The path to the collection within `modifiable`.
        let path = EmptyModifiable.path.attributes[0].attributes["table"].wrappedValue.tableValue

        /// The content of this view.
        var body: some View {
            TableViewPreviewView(
                viewModel: TableViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Root",
                    columns: [
                        .init(name: "b", type: .bool),
                        .init(name: "i", type: .integer),
                        .init(name: "f", type: .float)
                    ]
                )
            )
        }

    }

    /// A view that renders a `TableView` preview containing
    /// a table that does not exist within a `Modifiable` object.
    struct Binding_Preview: View {

        /// The table.
        @State var value: [[LineAttribute]] = []

        /// The contents of this view.
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

    /// A view that provides a @StateObject `TableViewModel` that is passed to
    /// a `TableView`.
    struct TableViewPreviewView: View {

        /// The view model associated with the `TableView`.
        @StateObject var viewModel: TableViewModel

        /// Create a new `TableView`, passing `viewModel` to it.
        var body: some View {
            TableView(viewModel: viewModel)
        }

    }

    /// All previews associated with `TableView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}

#endif
