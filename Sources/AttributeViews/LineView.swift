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

public struct LineView: View {
    
    @ObservedObject var viewModel: LineViewModel
    
//    @EnvironmentObject var config: Config
    
    public init(viewModel: LineViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(viewModel.label, text: $viewModel.editingValue, onEditingChanged: viewModel.onEditingChanged)
                .font(.body)
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

//struct LineView_Previews: PreviewProvider {
//    
//    struct Root_Preview: View {
//        
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "line", type: .line)], attributes: ["line": .line("hello")], metaData: [:])
//        ])
//        
//        let path = EmptyModifiable.path.attributes[0].attributes["line"].wrappedValue.lineValue
//        
//        var body: some View {
//            LineView(
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
//        @State var value: String = "world"
//        @State var errors: [String] = ["An error", "A second error"]
//        
//        var body: some View {
//            LineView(value: $value, errors: $errors, label: "Binding")
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
