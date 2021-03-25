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

public struct LineAttributeView<Config: AttributeViewConfig>: View {
    
    @Binding var attribute: LineAttribute
    @Binding var errors: [String]
    let label: String
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, LineAttribute>, label: String) {
        self.init(
            attribute: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        )
    }
    
    init(attribute: Binding<LineAttribute>, errors: Binding<[String]> = .constant([]), label: String) {
        self._attribute = attribute
        self._errors = errors
        self.label = label
    }
    
    public var body: some View {
        switch attribute.type {
        case .bool:
            BoolView<Config>(value: $attribute.boolValue, errors: $errors, label: label)
        case .integer:
            IntegerView<Config>(value: $attribute.integerValue, errors: $errors, label: label)
        case .float:
            FloatView<Config>(value: $attribute.floatValue, errors: $errors, label: label)
        case .expression(let language):
            ExpressionView<Config>(value: $attribute.expressionValue, errors: $errors, label: label, language: language)
        case .enumerated(let validValues):
            EnumeratedView<Config>(value: $attribute.enumeratedValue, errors: $errors, label: label, validValues: validValues)
        case .line:
            LineView<Config>(value: $attribute.lineValue, errors: $errors, label: label)
        }
    }
}

