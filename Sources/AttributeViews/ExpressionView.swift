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
    @Binding var errors: [String]
    let label: String
    let language: Language
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, language: Language) {
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
            language: language
        )
    }
    
    init(value: Binding<Expression>, errors: Binding<[String]> = .constant([]), label: String, language: Language) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value)
                .font(.body)
                .background(config.fieldColor)
                .foregroundColor(config.textColor)
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
        
    }
}
