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
    
    @Binding var value: Expression
    @State var errors: [String]
    let label: String
    let language: Language
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, language: Language) {
        let errors = State<[String]>(initialValue: root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message })
        self._value = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
            }
        )
        self._errors = errors
        self.label = label
        self.language = language
    }
    
    init(value: Binding<Expression>, label: String, language: Language) {
        self._value = value
        self._errors = State<[String]>(initialValue: [])
        self.label = label
        self.language = language
    }
    
    public var body: some View {
        TextField(label, text: $value)
            .font(.body)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
    }
}
