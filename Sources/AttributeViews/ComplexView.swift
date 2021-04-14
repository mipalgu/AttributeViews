//
//  ComplexView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes

public struct ComplexView<Config: AttributeViewConfig>: View {
    
    @Binding var value: [String: Attribute]
    @Binding var errors: [String]
    let subView: (Field) -> AttributeView<Config>
    let label: String
    let fields: [Field]
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field]) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message } },
                set: { _ in }
            ),
            label: label,
            fields: fields
        ){
            AttributeView(root: root, path: path[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    init(value: Binding<[String: Attribute]>, errors: Binding<[String]> = .constant([]), label: String, fields: [Field]) {
        self.init(value: value, errors: errors, label: label, fields: fields) {
            AttributeView(attribute: Binding(value[$0.name])!, label: $0.name.pretty)
        }
    }
    
    init(value: Binding<[String: Attribute]>, errors: Binding<[String]>, label: String, fields: [Field], subView: @escaping (Field) -> AttributeView<Config>) {
        self._value = value
        self._errors = errors
        self.label = label
        self.fields = fields
        self.subView = subView
    }
    
    public var body: some View {
        VStack {
            if !fields.isEmpty {
                Section(header: Text(label.capitalized).font(.title3)) {
                    VStack(alignment: .leading) {
                        ForEach(fields, id: \.name) { field in
                            subView(field)
                        }
                    }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
                }
            }
        }
    }
    
}

struct ComplexView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "complex", type: .complex(layout: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)]))],
                attributes: [
                    "complex": .complex(
                        ["bool": .bool(false), "integer": .integer(3)],
                        layout: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)])
                ],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["complex"].wrappedValue.complexValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ComplexView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                fields: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)]
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [String: Attribute] = [
            "s": .line("Hello"),
            "f": .float(3.12)
        ]
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ComplexView<DefaultAttributeViewsConfig>(
                value: $value,
                errors: $errors,
                label: "Binding",
                fields: ["s": .line, "f": .float]
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
