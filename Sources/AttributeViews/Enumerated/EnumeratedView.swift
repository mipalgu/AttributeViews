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

/// A view that displays and edits an enumerated property.
/// 
/// The view displays a Picker that allows a user to select the value of the
/// enumerated property and presents the errors associated with those edits
/// below the picker.
public struct EnumeratedView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: EnumeratedViewModel

    /// A set of values to choose from.
    let validValues: Set<String>

    /// Create a new `EnumeratedView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    /// 
    /// - Parameter validValues: A set of values to choose from.
    public init(viewModel: EnumeratedViewModel, validValues: Set<String>) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.validValues = validValues
    }

    /// The contents of this view.
    public var body: some View {
        VStack(alignment: .leading) {
            Picker(viewModel.label, selection: $viewModel.value) {
                ForEach(validValues.sorted(), id: \.self) {
                    Text($0).tag($0)
                        .focusable()
                }
            }
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }

}

// struct EnumeratedView_Previews: PreviewProvider {

//    struct Root_Preview: View {

//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields",
//                fields: [Field(name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))],
//                attributes: ["enumerated": .enumerated("b", validValues: ["a", "b", "c"])],
//                metaData: [:]
//             )
//        ])

//        let path = EmptyModifiable.path.attributes[0].attributes["enumerated"].wrappedValue.enumeratedValue

//        var body: some View {
//            EnumeratedView(
//                root: $modifiable,
//                path: path,
//                label: "Root",
//                validValues: ["a", "b", "c"]
//            )
//        }

//    }

//    struct Binding_Preview: View {

//        @State var value: String = "B"
//        @State var errors: [String] = ["An error", "A second error"]

//        var body: some View {
//            EnumeratedView(value: $value, errors: $errors, label: "Binding", validValues: ["A", "B", "C"])
//        }

//    }

//    static var previews: some View {
//        VStack {
//            Root_Preview()
//            Binding_Preview()
//        }
//    }

// }
