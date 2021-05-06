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
    
    let subView: () -> AnyView
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, LineAttribute>, label: String, notifier: GlobalChangeNotifier? = nil) {
        self.subView = {
            switch root.wrappedValue[keyPath: path.keyPath].type {
            case .bool:
                return AnyView(BoolView<Config>(root: root, path: path.boolValue, label: label, notifier: notifier))
            case .integer:
                return AnyView(IntegerView<Config>(root: root, path: path.integerValue, label: label, notifier: notifier))
            case .float:
                return AnyView(FloatView<Config>(root: root, path: path.floatValue, label: label, notifier: notifier))
            case .expression(let language):
                return AnyView(ExpressionView<Config>(root: root, path: path.expressionValue, label: label, language: language, notifier: notifier))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView<Config>(root: root, path: path.enumeratedValue, label: label, validValues: validValues, notifier: notifier))
            case .line:
                return AnyView(LineView<Config>(root: root, path: path.lineValue, label: label, notifier: notifier))
            }
        }
    }
    
    public init(attribute: Binding<LineAttribute>, errors: Binding<[String]> = .constant([]), label: String) {
        self.subView = {
            switch attribute.wrappedValue.type {
            case .bool:
                return AnyView(BoolView<Config>(value: attribute.boolValue, errors: errors, label: label))
            case .integer:
                return AnyView(IntegerView<Config>(value: attribute.integerValue, errors: errors, label: label))
            case .float:
                return AnyView(FloatView<Config>(value: attribute.floatValue, errors: errors, label: label))
            case .expression(let language):
                return AnyView(ExpressionView<Config>(value: attribute.expressionValue, errors: errors, label: label, language: language))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView<Config>(value: attribute.enumeratedValue, errors: errors, label: label, validValues: validValues))
            case .line:
                return AnyView(LineView<Config>(value: attribute.lineValue, errors: errors, label: label))
            }
        }
    }
    
    public var body: some View {
        subView()
    }
}

