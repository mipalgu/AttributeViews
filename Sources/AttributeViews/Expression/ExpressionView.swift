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
import Combine
#endif

import Attributes

public struct ExpressionView: View {

    @ObservedObject var viewModel: ExpressionViewModel

    public init(viewModel: ExpressionViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            TextField(viewModel.label, text: $viewModel.editingValue, onEditingChanged: viewModel.onEditingChanged)
                .font(.body)
                .focusable()
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

//struct ExpressionView_Previews: PreviewProvider {
//    
//    struct Root_Preview: View {
//        
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "expression", type: .expression(language: .swift))], attributes: ["expression": .expression("let i = 2", language: .swift)], metaData: [:])
//        ])
//        
//        let path = EmptyModifiable.path.attributes[0].attributes["expression"].wrappedValue.expressionValue
//        
//        var body: some View {
//            ExpressionView(
//                root: $modifiable,
//                path: path,
//                label: "Root",
//                language: .swift
//            )
//        }
//        
//    }
//    
//    struct Binding_Preview: View {
//        
//        @State var value: Expression = "let b = true"
//        @State var errors: [String] = ["An error", "A second error"]
//        
//        var body: some View {
//            ExpressionView(value: $value, errors: $errors, label: "Binding", language: .swift)
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
