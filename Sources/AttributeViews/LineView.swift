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
        self._errors = State<[String]>(initialValue: [])
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value)
                .background(config.fieldColor)
                .foregroundColor(config.textColor)
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
