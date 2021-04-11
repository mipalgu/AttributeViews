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

public struct FloatView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: Double
    
    @Binding var value: Double
    @Binding var errors: [String]
    let label: String
    let onCommit: ((Double) -> Void)?
    
    @EnvironmentObject var config: Config
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        return formatter
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Double>, label: String) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        ) {
            _ = try? root.wrappedValue.modify(attribute: path, value: $0)
        }
    }
    
    public init(value: Binding<Double>, errors: Binding<[String]> = .constant([]), label: String) {
        self.init(value: value, errors: errors, label: label, onCommit: nil)
    }
    
    private init(value: Binding<Double>, errors: Binding<[String]>, label: String, onCommit: ((Double) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, value: $editingValue, formatter: formatter, onEditingChanged: { if !$0 { onCommit(editingValue); editingValue = value } })
                    .font(.body)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .onChange(of: value) { editingValue = $0 }
            } else {
                TextField(label, value: $value, formatter: formatter)
                    .font(.body)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}
