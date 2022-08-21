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

/// A view that displays and edits an float property.
/// 
/// The view displays a `TextField` that allows a user to edit the value of the
/// float property and presents the errors associated with those edits below
/// the text field.
public struct FloatView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: FloatViewModel

    /// The number formatter that is utilised by the views text field to
    /// enable floating point values.
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        return formatter
    }

    /// Create a new `FloatView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: FloatViewModel) {
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

// struct FloatView_Previews: PreviewProvider {

//    struct Root_Preview: View {

//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields",
//                fields: [Field(name: "float", type: .float)],
//                attributes: ["float": .float(0.1)],
//                metaData: [:]
//             )
//        ])

//        let path = EmptyModifiable.path.attributes[0].attributes["float"].wrappedValue.floatValue

//        var body: some View {
//            FloatView(
//                root: $modifiable,
//                path: path,
//                label: "Root"
//            )
//        }

//    }

//    struct Binding_Preview: View {

//        @State var value: Double = 12.5123
//        @State var errors: [String] = ["An error", "A second error"]

//        var body: some View {
//            FloatView(value: $value, errors: $errors, label: "Binding")
//        }

//    }

//    static var previews: some View {
//        VStack {
//            Root_Preview()
//            Binding_Preview()
//        }
//    }
// }
