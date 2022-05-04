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

public struct TextView: View {
    
    @Binding var value: String
    @Binding var errors: [String]
    let label: String
    let onCommit: ((String) -> Void)?
    
//    @EnvironmentObject var config: Config
    
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
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
//                .foregroundColor(config.textColor)
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
        }
    }
}

#if canImport(SwiftUI)
struct TextView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "text", type: .text)], attributes: ["text": .text("some text\non different lines")], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["text"].wrappedValue.textValue
        
        var body: some View {
            TextView(
                root: $modifiable,
                path: path,
                label: "Root"
            )
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: String = "More text\non separate lines"
        @State var errors: [String] = ["An error", "A second error"]
        
        var body: some View {
            TextView(value: $value, errors: $errors, label: "Binding")
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
