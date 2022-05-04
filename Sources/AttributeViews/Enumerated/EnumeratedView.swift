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

public struct EnumeratedView: View {
    
    @ObservedObject var viewModel: EnumeratedViewModel
    let validValues: Set<String>
    
    public init(viewModel: EnumeratedViewModel, validValues: Set<String>) {
        self.viewModel = viewModel
        self.validValues = validValues
    }
    
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

//struct EnumeratedView_Previews: PreviewProvider {
//    
//    struct Root_Preview: View {
//        
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))], attributes: ["enumerated": .enumerated("b", validValues: ["a", "b", "c"])], metaData: [:])
//        ])
//        
//        let path = EmptyModifiable.path.attributes[0].attributes["enumerated"].wrappedValue.enumeratedValue
//        
//        var body: some View {
//            EnumeratedView(
//                root: $modifiable,
//                path: path,
//                label: "Root",
//                validValues: ["a", "b", "c"]
//            )
//        }
//        
//    }
//    
//    struct Binding_Preview: View {
//        
//        @State var value: String = "B"
//        @State var errors: [String] = ["An error", "A second error"]
//        
//        var body: some View {
//            EnumeratedView(value: $value, errors: $errors, label: "Binding", validValues: ["A", "B", "C"])
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
