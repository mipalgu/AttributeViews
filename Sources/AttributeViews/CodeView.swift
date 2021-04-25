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
    
    @State var editingValue: Code
    
    @Binding var value: Code
    @Binding var errors: [String]
    
    let label: () -> Label
    let language: Language
    let onCommit: ((Code) -> Void)?
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language) where Label == Text {
        self.init(root: root, path: path, language: language, label: { Text(label.capitalized) })
    }
    
    public init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language) where Label == Text {
        self.init(value: value, errors: errors, language: language, label: { Text(label.capitalized) }, onCommit: nil)
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, label: @escaping () -> Label) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            language: language,
            label: label
        ) {
            _ = try? root.wrappedValue.modify(attribute: path, value: $0)
        }
    }
    
    public init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, label: @escaping () -> Label, onCommit: ((Code) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            Group {
                if let onCommit = onCommit {
                    TextEditor(text: $editingValue)
                        .disableAutocorrection(true)
                        .onChange(of: editingValue) {
                            if $0 == value {
                                return
                            }
                            onCommit($0)
                            value = $0
                        }.onChange(of: value) {
                            if $0 == editingValue {
                                return
                            }
                            editingValue = $0
                        }
                } else {
                    TextEditor(text: $value).disableAutocorrection(true)
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
            .frame(minHeight: 80)
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "code", type: .code(language: .swift))], attributes: ["code": .code("let i = 2\nletb = true", language: .swift)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["code"].wrappedValue.codeValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            CodeView<DefaultAttributeViewsConfig, Text>(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "let f = 2.3\nlet s = \"hello\""
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            CodeView<DefaultAttributeViewsConfig, Text>(value: $value, errors: $errors, label: "Binding", language: .swift).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
