//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes

public struct BoolView<Config: AttributeViewConfig>: View {
    
    @Binding var value: Bool
    @Binding var errors: [String]
    
    let label: String
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Bool>, label: String) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        )
    }
    
    public init(value: Binding<Bool>, errors: Binding<[String]> = .constant([]), label: String) {
        self._value = value
        self._errors = errors
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Toggle(label, isOn: $value)
                .animation(.easeOut)
                .font(.body)
//                .foregroundColor(config.textColor)
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

struct BoolView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "bool", type: .bool)],
                attributes: ["bool": .bool(false)],
                metaData: [:]
            )
        ])
        
        let config = DefaultAttributeViewsConfig()
        
        let path = EmptyModifiable.path.attributes[0].attributes["bool"].wrappedValue.boolValue
        
        var body: some View {
            BoolView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Bool = false
        
        @State var errors: [String] = ["An Error."]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            BoolView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}

