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

public struct CodeView<Label: View>: View {
    
    @Binding var value: Code
    @Binding var errors: [String]
    
    let label: () -> Label
    let language: Language
    let onCommit: ((Code) -> Void)?
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language, notifier: GlobalChangeNotifier? = nil) where Label == Text {
        self.init(root: root, path: path, language: language, notifier: notifier, label: { Text(label.capitalized) })
    }
    
    public init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language, delayEdits: Bool = false) where Label == Text {
        self.init(value: value, errors: errors, language: language, delayEdits: delayEdits, label: { Text(label.capitalized) })
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, notifier: GlobalChangeNotifier? = nil, label: @escaping () -> Label) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? "" : root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            language: language,
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
    
    public init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, delayEdits: Bool = false, label: @escaping () -> Label) {
        self.init(value: value, errors: errors, language: language, label: label, onCommit: delayEdits ? { value.wrappedValue = $0 } : nil)
    }
    
    private init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, label: @escaping () -> Label, onCommit: ((Code) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            Group {
                GeometryReader { geometry in
                    Editor(editingText: $value, size: geometry.size, onCommit: onCommit)
                        .focusable()
                }.clipShape(RoundedRectangle(cornerRadius: 5))
            }.overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
            .frame(minHeight: 80)
        }
    }
}

#if canImport(SwiftUI)
struct CodeView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "code", type: .code(language: .swift))], attributes: ["code": .code("let i = 2\nletb = true", language: .swift)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["code"].wrappedValue.codeValue
        
        var body: some View {
            CodeView(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift
            )
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "let f = 2.3\nlet s = \"hello\""
        @State var errors: [String] = ["An error", "A second error"]
        
        var body: some View {
            CodeView(value: $value, errors: $errors, label: "Binding", language: .swift)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
#endif
