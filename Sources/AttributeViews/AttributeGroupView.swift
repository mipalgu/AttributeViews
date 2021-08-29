//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//


#if canImport(TokamakShim)
import TokamakShim
typealias Form = VStack
#else
import SwiftUI
#endif

import Attributes

public struct AttributeGroupView: View {
    
    @ObservedObject var viewModel: AttributeGroupViewModel
    
    public init(viewModel: AttributeGroupViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                ComplexView(viewModel: viewModel.complexViewModel)
            }
        }
    }
    
}

import GUUI
#if canImport(SwiftUI)
struct AttributeGroupView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "float", type: .float)],
                attributes: ["float": .float(0.1)],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0]
        
        var body: some View {
            AttributeGroupPreviewView(
                viewModel: AttributeGroupViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path
                )
            )
        }
        
    }
    
    struct AttributeGroupPreviewView: View {
        
        @StateObject var viewModel: AttributeGroupViewModel
        
        var body: some View {
            AttributeGroupView(viewModel: viewModel)
        }
        
    }
    
//    struct Binding_Preview: View {
//
//        @State var value: AttributeGroup = AttributeGroup(
//            name: "Binding",
//            fields: [Field(name: "s", type: .line)],
//            attributes: ["s": .line("Hello")],
//            metaData: [:]
//        )
//
//        let config = DefaultAttributeViewsConfig()
//
//        var body: some View {
//            AttributeGroupView<DefaultAttributeViewsConfig>(value: $value, label: "Binding").environmentObject(config)
//        }
//
//    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
//            Binding_Preview()
        }
    }
}
#endif
