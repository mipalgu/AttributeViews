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

public struct AttributeGroupView<Config: AttributeViewConfig>: View {
    
    let subView: () -> ComplexView<Config>
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String, expanded: Binding<[AnyKeyPath: Bool]>? = nil) {
        self.init {
            ComplexView(root: root, path: path.attributes, label: label, fields: root.wrappedValue[keyPath: path.keyPath].fields, expanded: expanded)
        }
    }
    
    private init(subView: @escaping () -> ComplexView<Config>) {
        self.subView = subView
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                subView()
            }
        }
    }
    
}

struct AttributeGroupView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            AttributeGroupView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
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
