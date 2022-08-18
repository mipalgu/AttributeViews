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

public struct FloatView: View {

    @ObservedObject var viewModel: FloatViewModel

    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        return formatter
    }

    public init(viewModel: FloatViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

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

//struct FloatView_Previews: PreviewProvider {
//    
//    struct Root_Preview: View {
//        
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
//        ])
//        
//        let path = EmptyModifiable.path.attributes[0].attributes["float"].wrappedValue.floatValue
//        
//        var body: some View {
//            FloatView(
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
//        @State var value: Double = 12.5123
//        @State var errors: [String] = ["An error", "A second error"]
//        
//        var body: some View {
//            FloatView(value: $value, errors: $errors, label: "Binding")
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
