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

public struct IntegerView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: Int
    
    @Binding var value: Int
    @Binding var errors: [String]
    let label: String
    let onCommit: ((Int) -> Void)?
    
    @EnvironmentObject var config: Config
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Int>, label: String) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        ) {
            _ = try? root.wrappedValue.modify(attribute: path, value: $0)
        }
    }
    
    public init(value: Binding<Int>, errors: Binding<[String]> = .constant([]), label: String) {
        self.init(value: value, errors: errors, label: label, onCommit: nil)
    }
    
    private init(value: Binding<Int>, errors: Binding<[String]>, label: String, onCommit: ((Int) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, value: $editingValue, formatter: formatter, onEditingChanged: { if !$0 { onCommit(editingValue); editingValue = value } })
                    .font(.body)
                    .border(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .onChange(of: value) { editingValue = $0 }
            } else {
                TextField(label, value: $value, formatter: formatter)
                    .font(.body)
                    .border(config.fieldColor)
                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
        
    }
}

struct IntegerView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "integer", type: .integer)], attributes: ["integer": .integer(0)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["integer"].wrappedValue.integerValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            IntegerView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Int = 12
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            IntegerView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
