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

public struct LineView<Config: AttributeViewConfig>: View {
    
    @State var editingValue: String
    
    @Binding var value: String
    @Binding var errors: [String]
    let label: String
    let onCommit: ((String) -> Void)?
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, String>, label: String) {
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
    
    public init(value: Binding<String>, errors: Binding<[String]> = .constant([]), label: String) {
        self.init(value: value, errors: errors, label: label, onCommit: nil)
    }
    
    private init(value: Binding<String>, errors: Binding<[String]>, label: String, onCommit: ((String) -> Void)?) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
        self._editingValue = State(initialValue: value.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let onCommit = onCommit {
                TextField(label, text: $editingValue, onEditingChanged: { if !$0 { onCommit(editingValue); editingValue = value } })
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .onChange(of: value) { editingValue = $0 }
            } else {
                TextField(label, text: $value)
                    .background(config.textColor)
                    .foregroundColor(config.textColor)
            }
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

//import Machines
//
//struct LineView_Preview: PreviewProvider {
//
//    static let root: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine())
//
//    static var previews: some View {
//        LineView(
//            root: root,
//            path: Machine.path.states[0].name,
//            label: "State 0"
//        ).environmentObject(Config())
//    }
//
//}
