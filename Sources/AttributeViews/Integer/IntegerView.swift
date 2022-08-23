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

// swiftlint:disable type_contents_order

/// A view that displays and edits an integer property.
/// 
/// The view displays a `TextField` that allows a user to edit the value of the
/// integer property and presents the errors associated with those edits below
/// the text field.
public struct IntegerView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: IntegerViewModel

    /// The number formatter that is utilised by the views text field to
    /// disallow floating point values.
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }

    /// Create a new `IntegerView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: IntegerViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(
                viewModel.label,
                value: $viewModel.editingValue,
                formatter: formatter,
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

// struct IntegerView_Previews: PreviewProvider {

//    struct Root_Preview: View {

//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields",
//                fields: [Field(name: "integer", type: .integer)],
//                attributes: ["integer": .integer(0)],
//                metaData: [:]
//             )
//        ])

//        let path = EmptyModifiable.path.attributes[0].attributes["integer"].wrappedValue.integerValue

//        var body: some View {
//            IntegerView(
//                root: $modifiable,
//                path: path,
//                label: "Root"
//            )
//        }

//    }

//    struct Binding_Preview: View {

//        @State var value: Int = 12
//        @State var errors: [String] = ["An error", "A second error"]

//        var body: some View {
//            IntegerView(value: $value, errors: $errors, label: "Binding")
//        }

//    }

//    static var previews: some View {
//        VStack {
//            Root_Preview()
//            Binding_Preview()
//        }
//    }

// }
