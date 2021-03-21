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

public struct FloatView: View {
    
    @Binding var value: Double
    @State var errors: [String]
    let label: String
    
    @EnvironmentObject var config: Config
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.alwaysShowsDecimalSeparator = true
        return formatter
    }
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Double>, label: String) {
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
    
    init(value: Binding<Double>, label: String) {
        self._value = value
        self._errors = State<[String]>(initialValue: [])
        self.label = label
    }
    
    public var body: some View {
        TextField(label, value: $value, formatter: formatter)
            .font(.body)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
    }
}
