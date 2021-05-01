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

final class AttributeViewModel: ObservableObject {
    
    let value: Binding<Attribute>
    
    var attribute: Attribute {
        get {
            value.wrappedValue
        } set {
            value.wrappedValue = newValue
            objectWillChange.send()
        }
    }
    
    var blockAttribute: BlockAttribute {
        get {
            value.wrappedValue.blockAttribute
        } set {
            value.wrappedValue.blockAttribute = newValue
            objectWillChange.send()
        }
    }
    
    var lineAttribute: LineAttribute {
        get {
            value.wrappedValue.lineAttribute
        } set {
            value.wrappedValue.lineAttribute = newValue
            objectWillChange.send()
        }
    }
    
    init(value: Binding<Attribute>) {
        self.value = value
    }
    
}

public struct AttributeGroupView<Config: AttributeViewConfig>: View {
    
    let value: Binding<AttributeGroup>
    let errors: Binding<[String]>
    let subErrors: (ReadOnlyPath<[String: Attribute], Attribute>) -> [String]
    let label: String
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? AttributeGroup(name: "") : root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: path).map(\.message) },
                set: { _ in }
            ),
            subErrors: {
                root.wrappedValue.errorBag.errors(includingDescendantsForPath: ReadOnlyPath(keyPath: path.attributes.keyPath.appending(path: $0.keyPath), ancestors: path.ancestors)).map(\.message)
            },
            label: label
        )
    }
    
    public init(value: Binding<AttributeGroup>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (Attributes.ReadOnlyPath<[String: Attribute], Attribute>) -> [String], label: String) {
        self.value = value
        self.errors = errors
        self.subErrors = subErrors
        self.label = label
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                ComplexView<Config>(value: value.attributes, errors: errors, subErrors: subErrors, label: label, fields: value.wrappedValue.fields)
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
