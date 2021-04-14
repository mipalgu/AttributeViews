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
    
    @Binding var value: AttributeGroup
    let label: String
    let subView: (Field) -> AttributeView<Config>
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            label: label
        ) {
            AttributeView(root: root, path: path.attributes[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    public init(value: Binding<AttributeGroup>, label: String) {
        self.init(value: value, label: label) { field in
            AttributeView(
                attribute: Binding(
                    get: { value.attributes[field.name].wrappedValue! },
                    set: { value.attributes[field.name].wrappedValue = $0 }
                ),
                label: field.name.pretty
            )
        }
    }
    
    private init(value: Binding<AttributeGroup>, label: String, subView: @escaping (Field) -> AttributeView<Config>) {
        self._value = value
        self.label = label
        self.subView = subView
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        if !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(label.pretty).font(.title2)
                            Divider()
                        }
                        ForEach(value.fields, id: \.name) { field in
                            subView(field)
                            Divider()
                        }
                    }
                    Spacer()
                }
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
    
    struct Binding_Preview: View {
        
        @State var value: AttributeGroup = AttributeGroup(
            name: "Binding",
            fields: [Field(name: "s", type: .line)],
            attributes: ["s": .line("Hello")],
            metaData: [:]
        )
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            AttributeGroupView<DefaultAttributeViewsConfig>(value: $value, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
