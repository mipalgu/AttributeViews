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

// swiftlint:disable type_contents_order

/// A view that displays and edits an expression property.
/// 
/// The view displays a `TextField` that allows a user to edit the value of the
/// expression property and presents the errors associated with those edits
/// below the text field.
public struct ExpressionView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: ExpressionViewModel

    /// Create a new `ExpressionViewModel`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: ExpressionViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(
                viewModel.label,
                text: $viewModel.editingValue,
                onEditingChanged: viewModel.onEditingChanged
            )
            .font(.body)
            .focusable()
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

// struct ExpressionView_Previews: PreviewProvider {

//    struct Root_Preview: View {

//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields",
//                fields: [Field(name: "expression", type: .expression(language: .swift))],
//                attributes: ["expression": .expression("let i = 2", language: .swift)],
//                metaData: [:]
//             )
//        ])

//        let path = EmptyModifiable.path.attributes[0].attributes["expression"].wrappedValue.expressionValue

//        var body: some View {
//            ExpressionView(
//                root: $modifiable,
//                path: path,
//                label: "Root",
//                language: .swift
//            )
//        }

//    }

//    struct Binding_Preview: View {

//        @State var value: Expression = "let b = true"
//        @State var errors: [String] = ["An error", "A second error"]

//        var body: some View {
//            ExpressionView(value: $value, errors: $errors, label: "Binding", language: .swift)
//        }

//    }

//    static var previews: some View {
//        VStack {
//            Root_Preview()
//            Binding_Preview()
//        }
//    }
// }
