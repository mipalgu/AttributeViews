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

public struct LineView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: String
    @State var editing: Bool = false
    
    @Binding var value: String
    @Binding var errors: [String]
    let label: String
    let onCommit: ((String) -> Void)?
    
//    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, String?>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? "" : root.wrappedValue[keyPath: path.keyPath] ?? "" },
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
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, String>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? "" : root.wrappedValue[keyPath: path.keyPath] },
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
    
    public init(value: Binding<String>, errors: Binding<[String]> = .constant([]), label: String, delayEdits: Bool = false) {
        self.init(value: value, errors: errors, label: label, onCommit: delayEdits ? { value.wrappedValue = $0 } : nil)
    }
    
    private init(value: Binding<String>, errors: Binding<[String]>, label: String, onCommit: ((String) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, text: $editingValue, onEditingChanged: { self.editing = $0; if !$0 { onCommit(editingValue); editingValue = value } })
//                    .border(config.fieldColor)
//                    .foregroundColor(config.textColor)
                    .onReceive(Just(value)) { _ in
                        if !editing {
                            editingValue = value
                        }
                    }
            } else {
                TextField(label, text: $value)
//                    .border(config.fieldColor)
//                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "line", type: .line)], attributes: ["line": .line("hello")], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["line"].wrappedValue.lineValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            LineView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "world"
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            LineView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
