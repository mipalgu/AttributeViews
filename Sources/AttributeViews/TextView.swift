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

public struct TextView<Config: AttributeViewConfig>: View {
    
    @Binding var value: String
    @Binding var errors: [String]
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, String>, label: String) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { try? root.wrappedValue.modify(attribute: path, value: $0) }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        )
    }
    
    public init(value: Binding<String>, errors: Binding<[String]> = .constant([]), label: String) {
        self._value = value
        self._errors = errors
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            TextEditor(text: $value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
        }
    }
}

struct TextView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "text", type: .text)], attributes: ["text": .text("some text\non different lines")], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["text"].wrappedValue.textValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TextView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "More text\non separate lines"
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            TextView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
