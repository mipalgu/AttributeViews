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

public struct BoolView<Config: AttributeViewConfig>: View {
    
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

import Machines

struct BoolView_Previews: PreviewProvider {
    
    struct BoolViewRoot_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        let config = DefaultAttributeViewsConfig()
        
        let path = Machine.path
            .attributes[1]
            .attributes["use_custom_ringlet"]
            .wrappedValue
            .boolValue
        
        var body: some View {
            BoolView<DefaultAttributeViewsConfig>(
                root: $machine,
                path: path,
                label: "Machine"
            ).environmentObject(config)
        }
        
    }
    
    struct BoolViewBinding_Preview: View {
        
        @State var value: Bool = false
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            BoolView<DefaultAttributeViewsConfig>(value: $value, label: "Binding").environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            BoolViewRoot_Preview()
            BoolViewBinding_Preview()
        }
    }
}

