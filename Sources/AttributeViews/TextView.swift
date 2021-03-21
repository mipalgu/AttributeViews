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

public struct TextView<Config: AttributeViewConfig>: View {
    
    @Binding var value: String
    @State var errors: [String]
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, String>, label: String) {
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
    }
    
    init(value: Binding<String>, label: String) {
        self._value = value
        self._errors = State(initialValue: [])
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: $value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
        }
    }
}
