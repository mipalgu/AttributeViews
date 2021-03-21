//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes

public struct BoolView: View {
    
    @Binding var value: Bool
    @Binding var errors: [String]
    
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Bool>, label: String) {
        self._value = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: { _ = try? root.wrappedValue.modify(attribute: path, value: $0) }
        )
        self._errors = Binding(
            get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message } },
            set: { _ in }
        )
        self.label = label
    }
    
    init(value: Binding<Bool>, label: String) {
        self._value = value
        var errors: [String] = []
        self._errors = Binding(get: { errors }, set: { errors = $0 })
        self.label = label
    }
    
    public var body: some View {
        Toggle(label, isOn: $value)
            .animation(.easeOut)
            .font(.body)
            .foregroundColor(config.textColor)
    }
}

