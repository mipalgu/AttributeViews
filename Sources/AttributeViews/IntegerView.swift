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

import Combine

import Attributes

public struct IntegerView: View {
    
    @ObservedObject var viewModel: IntegerViewModel
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }
    
    public init(viewModel: IntegerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(viewModel.label, value: $viewModel.editingValue, formatter: formatter, onEditingChanged: viewModel.onEditingChanged)
                .font(.body)
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

//struct IntegerView_Previews: PreviewProvider {
//
//    struct Root_Preview: View {
//
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "integer", type: .integer)], attributes: ["integer": .integer(0)], metaData: [:])
//        ])
//
//        let path = EmptyModifiable.path.attributes[0].attributes["integer"].wrappedValue.integerValue
//
//        var body: some View {
//            IntegerView(
//                root: $modifiable,
//                path: path,
//                label: "Root"
//            )
//        }
//
//    }
//
//    struct Binding_Preview: View {
//
//        @State var value: Int = 12
//        @State var errors: [String] = ["An error", "A second error"]
//
//        var body: some View {
//            IntegerView(value: $value, errors: $errors, label: "Binding")
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
