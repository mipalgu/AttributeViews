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
import Combine
#endif

import Combine

import Attributes

public struct ExpressionView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: Expression
    @State var editing: Bool = false
    
    @Binding var value: Expression
    @Binding var errors: [String]
    let label: String
    let language: Language
    let onCommit: ((Expression) -> Void)?
    
    //@EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, language: Language, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? "" : root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label,
            language: language
        ) {
            let result = root.wrappedValue.modify(attribute: path, value: $0)
            switch result {
            case .success(true), .failure:
                notifier?.send()
            default: return
            }
        }
    }
    
    public init(value: Binding<Expression>, errors: Binding<[String]> = .constant([]), label: String, language: Language) {
        self.init(value: value, errors: errors, label: label, language: language, onCommit: nil)
    }
    
    private init(value: Binding<Expression>, errors: Binding<[String]>, label: String, language: Language, onCommit: ((Expression) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, text: $editingValue, onEditingChanged: { self.editing = $0; if !$0 { onCommit(editingValue); editingValue = value } })
                    .font(.body)
//                    .border(config.fieldColor)
//                    .foregroundColor(config.textColor)
                    .onReceive(Just(value)) { _ in
                        if !editing {
                            editingValue = value
                        }
                    }
            } else {
                TextField(label, text: $value)
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

struct ExpressionView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "expression", type: .expression(language: .swift))], attributes: ["expression": .expression("let i = 2", language: .swift)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["expression"].wrappedValue.expressionValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ExpressionView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Expression = "let b = true"
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ExpressionView<DefaultAttributeViewsConfig>(value: $value, errors: $errors, label: "Binding", language: .swift).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
