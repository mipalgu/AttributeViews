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

public struct EnumeratedView<Config: AttributeViewConfig>: View {
    
    @Binding var value: Expression
    @State var errors: [String]
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Expression>, label: String, validValues: Set<String>) {
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
        self.validValues = validValues
    }
    
    init(value: Binding<Expression>, label: String, validValues: Set<String>) {
        self._value = value
        self._errors = State<[String]>(initialValue: [])
        self.label = label
        self.validValues = validValues
    }
    
    public var body: some View {
        Picker(label, selection: $value) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }
    }
}
