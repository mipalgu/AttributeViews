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

public struct LineAttributeView: View {
    
    let subView: () -> AnyView
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, LineAttribute>, label: String) {
        self.subView = {
            switch root.wrappedValue[keyPath: path.keyPath].type {
            case .bool:
                return AnyView(BoolView(root: root, path: path.boolValue, label: label))
            case .integer:
                return AnyView(IntegerView(root: root, path: path.integerValue, label: label))
            case .float:
                return AnyView(FloatView(root: root, path: path.floatValue, label: label))
            case .expression(let language):
                return AnyView(ExpressionView(root: root, path: path.expressionValue, label: label, language: language))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView(root: root, path: path.enumeratedValue, label: label, validValues: validValues))
            case .line:
                return AnyView(LineView(root: root, path: path.lineValue, label: label))
            }
        }
    }
    
    init(attribute: Binding<LineAttribute>, label: String) {
        self.subView = {
            switch attribute.wrappedValue.type {
            case .bool:
                return AnyView(BoolView(value: attribute.boolValue, label: label))
            case .integer:
                return AnyView(IntegerView(value: attribute.integerValue, label: label))
            case .float:
                return AnyView(FloatView(value: attribute.floatValue, label: label))
            case .expression(let language):
                return AnyView(ExpressionView(value: attribute.expressionValue, label: label, language: language))
            case .enumerated(let validValues):
                return AnyView(EnumeratedView(value: attribute.enumeratedValue, label: label, validValues: validValues))
            case .line:
                return AnyView(LineView(value: attribute.lineValue, label: label))
            }
        }
    }
    
    public var body: some View {
        subView()
    }
}

