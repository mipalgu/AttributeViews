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

final class ComplexViewModel: ObservableObject {
    
    let value: Binding<[String: Attribute]>
    
    let errorsBinding: Binding<[String]>
    
    let subErrors: (ReadOnlyPath<[String: Attribute], Attribute>) -> [String]
    
    private var attributesViewModels: [String: AttributeViewModel] = [:]
    
    var errors: [String] {
        errorsBinding.wrappedValue
    }
    
    public var attributes: [String: AttributeViewModel] {
        get {
            Dictionary(uniqueKeysWithValues: value.wrappedValue.keys.map { key in
                if let viewModel = attributesViewModels[key] {
                    return (key, viewModel)
                }
                let viewModel = AttributeViewModel(
                    value: Binding(
                        get: { self.value.wrappedValue[key] ?? .bool(false) },
                        set: { self.value.wrappedValue[key] = $0 }
                    )
                )
                attributesViewModels[key] = viewModel
                return (key, viewModel)
            })
        } set {
            value.wrappedValue = newValue.mapValues {
                $0.value.wrappedValue
            }
            objectWillChange.send()
        }
    }
    
    init(value: Binding<[String: Attribute]>, errors: Binding<[String]>, subErrors: @escaping (ReadOnlyPath<[String: Attribute], Attribute>) -> [String]) {
        self.value = value
        self.errorsBinding = errors
        self.subErrors = subErrors
    }
    
    func errorBinding(forAttribute fieldName: String) -> Binding<[String]> {
        return Binding(
            get: { self.errors(forAttributeAtPath: ReadOnlyPath<[String : Attribute], Attribute>(keyPath: \.[fieldName].wrappedValue, ancestors: [])) },
            set: { _ in }
        )
    }
    
    func subErrors(forAttribute fieldName: String) -> (ReadOnlyPath<Attribute, Attribute>) -> [String] {
        let keyPath: KeyPath<[String: Attribute], Attribute> = \.[fieldName].wrappedValue
        return {
            let path = ReadOnlyPath<[String: Attribute], Attribute>(keyPath: keyPath.appending(path: $0.keyPath), ancestors: [])
            return self.errors(forAttributeAtPath: path)
        }
    }
    
    func errors(forAttributeAtPath path: ReadOnlyPath<[String: Attribute], Attribute>) -> [String] {
        subErrors(path)
    }
    
}

public struct ComplexView<Config: AttributeViewConfig>: View {
    
    @StateObject var viewModel: ComplexViewModel
    let label: String
    let fields: [Field]
    
    //@EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field]) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? [:] : root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message } },
                set: { _ in }
            ),
            subErrors: {
                root.wrappedValue.errorBag.errors(includingDescendantsForPath: ReadOnlyPath(keyPath: path.keyPath.appending(path: $0.keyPath), ancestors: [])).map(\.message)
            },
            label: label,
            fields: fields
        )
    }
    
    public init(value: Binding<[String: Attribute]>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<[String: Attribute], Attribute>) -> [String] = { _ in [] }, label: String, fields: [Field]) {
        self.init(viewModel: ComplexViewModel(value: value, errors: errors, subErrors: subErrors), label: label, fields: fields)
    }
    
    private init(viewModel: ComplexViewModel, label: String, fields: [Field]) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self.fields = fields
    }
    
    public var body: some View {
        VStack {
            if !fields.isEmpty {
                Section(header: HStack {
                    Text(label.pretty).font(.headline)
                    Spacer()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            ForEach(fields, id: \.name) { field in
                                if viewModel.attributes[field.name]?.value.wrappedValue.isBlock == true {
                                    DisclosureGroup(field.name.pretty) {
                                        AttributeView<Config>(
                                            attribute: viewModel.attributes[field.name]?.value ?? .constant(.bool(false)),
                                            errors: viewModel.errorBinding(forAttribute: field.name),
                                            subErrors: viewModel.subErrors(forAttribute: field.name),
                                            label: ""
                                        )
                                    }
                                } else {
                                    AttributeView<Config>(
                                        attribute: viewModel.attributes[field.name]?.value ?? .constant(.bool(false)),
                                        errors: viewModel.errorBinding(forAttribute: field.name),
                                        subErrors: viewModel.subErrors(forAttribute: field.name),
                                        label: field.name.pretty
                                    )
                                    Spacer()
                                }
                            }
                        }.padding(10).background(Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05))
                        Spacer()
                    }
                }
            }
        }
    }
    
}

struct ComplexView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "complex", type: .complex(layout: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)]))],
                attributes: [
                    "complex": .complex(
                        ["bool": .bool(false), "integer": .integer(3)],
                        layout: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)])
                ],
                metaData: [:]
            )
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["complex"].wrappedValue.complexValue
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ComplexView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root",
                fields: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)]
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [String: Attribute] = [
            "s": .line("Hello"),
            "f": .float(3.12)
        ]
        @State var errors: [String] = ["An error", "A second error"]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            ComplexView<DefaultAttributeViewsConfig>(
                value: $value,
                errors: $errors,
                subErrors: { _ in [] },
                label: "Binding",
                fields: ["s": .line, "f": .float]
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
