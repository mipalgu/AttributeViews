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

public struct ExpressionView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: Expression
    
    @Binding var value: Expression
    @Binding var errors: [String]
    let label: String
    let language: Language
    let onCommit: ((Expression) -> Void)?
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, language: Language) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label,
            language: language
        ) {
            _ = try? root.wrappedValue.modify(attribute: path, value: $0)
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
                TextField(label, text: $editingValue, onEditingChanged: { if !$0 { onCommit(editingValue); editingValue = value } })
                    .font(.body)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .onChange(of: value) { editingValue = $0 }
            } else {
                TextField(label, text: $value)
                    .font(.body)
                    .background(config.textColor)
                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
        
    }
}
