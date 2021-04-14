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

public struct EnumeratedView<Config: AttributeViewConfig>: View {
    
    @Binding var value: Expression
    @Binding var errors: [String]
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, validValues: Set<String>) {
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
            label: label,
            validValues: validValues
        )
    }
    
    public init(value: Binding<Expression>, errors: Binding<[String]> = .constant([]), label: String, validValues: Set<String>) {
        self._value = value
        self._errors = errors
        self.label = label
        self.validValues = validValues
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Picker(label, selection: $value) {
                ForEach(validValues.sorted(), id: \.self) {
                    Text($0).tag($0)
                        .border(config.fieldColor)
                        .foregroundColor(config.textColor)
                }
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

struct EnumeratedView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))], attributes: ["enumerated": .enumerated("b", validValues: ["a", "b", "c"])], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["enumerated"].wrappedValue.enumeratedValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            EnumeratedView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                validValues: ["a", "b", "c"]
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "B"
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            EnumeratedView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding", validValues: ["A", "B", "C"]).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
