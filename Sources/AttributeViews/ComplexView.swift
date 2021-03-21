//
//  ComplexView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes

public struct ComplexView<Root: Modifiable>: View {
    
    @Binding var value: [String: Attribute]
    @State var errors: [String]
    let subView: (Field) -> AttributeView<Root>
    let label: String
    let fields: [Field]
    
    @EnvironmentObject var config: Config
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field]) {
        let errors = State<[String]>(initialValue: root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message })
        self._errors = errors
        self._value = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
            }
        )
        self.label = label
        self.fields = fields
        self.subView = {
            AttributeView(root: root, path: path[$0.name].wrappedValue, label: $0.name.pretty)
        }
    }
    
    init(root: Binding<Root>, value: Binding<[String: Attribute]>, label: String, fields: [Field]) {
        self._value = value
        self._errors = State<[String]>(initialValue: [])
        self.label = label
        self.fields = fields
        self.subView = {
            AttributeView(root: root, attribute: Binding(value[$0.name])!, label: $0.name.pretty)
        }
    }
    
    public var body: some View {
        VStack {
            if !fields.isEmpty {
                Section(header: Text(label.capitalized).font(.title3)) {
                    VStack(alignment: .leading) {
                        ForEach(fields, id: \.name) { field in
                            subView(field)
                        }
                    }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
                }
            }
        }
    }
}
