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

public struct FloatView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: Double
    @State var editing: Bool = false
    
    @Binding var value: Double
    @Binding var errors: [String]
    let label: String
    let onCommit: ((Double) -> Void)?
    
    //@EnvironmentObject var config: Config
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        return formatter
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Double>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? 0.0 : root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        ) {
            let result = root.wrappedValue.modify(attribute: path, value: $0)
            switch result {
            case .success(true), .failure:
                notifier?.send()
            default: return
            }
        }
    }
    
    public init(value: Binding<Double>, errors: Binding<[String]> = .constant([]), label: String) {
        self.init(value: value, errors: errors, label: label, onCommit: nil)
    }
    
    private init(value: Binding<Double>, errors: Binding<[String]>, label: String, onCommit: ((Double) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, value: $editingValue, formatter: formatter, onEditingChanged: { self.editing = $0; if !$0 { onCommit(editingValue); editingValue = value } })
                    .font(.body)
//                    .border(config.fieldColor)
//                    .foregroundColor(config.textColor)
                    .onReceive(Just(value)) { _ in
                        if !editing {
                            editingValue = value
                        }
                    }
            } else {
                TextField(label, value: $value, formatter: formatter)
                    .font(.body)
//                    .border(config.fieldColor)
//                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

struct FloatView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["float"].wrappedValue.floatValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            FloatView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Double = 12.5123
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            FloatView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
