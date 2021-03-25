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

public struct CodeView<Config: AttributeViewConfig, Label: View>: View {
    
    @Binding var value: Code
    @Binding var errors: [String]
    
    let label: () -> Label
    let language: Language
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language) where Label == Text {
        self.init(root: root, path: path, language: language, label: { Text(label.capitalized) })
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language) where Label == Text {
        self.init(value: value, errors: errors, language: language, label: { Text(label.capitalized) })
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, label: @escaping () -> Label) {
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
            language: language,
            label: label
        )
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, label: @escaping () -> Label) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            TextEditor(text: $value)
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
        }
    }
}
