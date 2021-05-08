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

fileprivate final class ComplexViewModel: ObservableObject {
    
    let value: Binding<[String: Attribute]>
    
    let subErrors: (ReadOnlyPath<[String: Attribute], Attribute>) -> [String]
    
    let expanded: Binding<[AnyKeyPath: Bool]>?
    
    let root: AnyKeyPath?
    
    private var attributesViewModels: [String: AttributeViewModel] = [:]
    
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
    
    init(value: Binding<[String: Attribute]>, subErrors: @escaping (ReadOnlyPath<[String: Attribute], Attribute>) -> [String], expanded: Binding<[AnyKeyPath: Bool]>?, root: AnyKeyPath?) {
        self.value = value
        self.subErrors = subErrors
        self.expanded = expanded
        self.root = root
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
    
    func expandedBinding(_ fieldName: String) -> Binding<Bool>? {
        guard expanded != nil, let root = root, let keyPath = root.appending(path: \[String: Attribute].[fieldName]) else {
            return nil
        }
        return Binding(
            get: { self.expanded?.wrappedValue[keyPath] ?? false },
            set: { self.expanded?.wrappedValue[keyPath] = $0 }
        )
    }
    
}

public struct ComplexView<Config: AttributeViewConfig>: View {
    
    @StateObject fileprivate var viewModel: ComplexViewModel
    @Binding var errors: [String]
    let label: String
    let fields: [Field]
    let subView: (String, String)-> AttributeView<Config>
    
    //@EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field], expanded: Binding<[AnyKeyPath: Bool]>? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            viewModel: ComplexViewModel(
                value: Binding(
                    get: { path.isNil(root.wrappedValue) ? [:] : root.wrappedValue[keyPath: path.keyPath] },
                    set: {
                        let result = root.wrappedValue.modify(attribute: path, value: $0)
                        switch result {
                        case .success(true), .failure:
                            notifier?.send()
                        default: return
                        }
                    }
                ),
                subErrors: {
                    root.wrappedValue.errorBag.errors(includingDescendantsForPath: ReadOnlyPath(keyPath: path.keyPath.appending(path: $0.keyPath), ancestors: [])).map(\.message)
                },
                expanded: expanded,
                root: path.keyPath
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message } },
                set: { _ in }
            ),
            label: label,
            fields: fields
        ) {
            AttributeView(root: root, path: path[$0].wrappedValue, label: $1, expanded: expanded, notifier: notifier)
        }
    }
    
    public init(value: Binding<[String: Attribute]>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<[String: Attribute], Attribute>) -> [String] = { _ in [] }, label: String, fields: [Field], delayEdits: Bool = false) {
        let viewModel = ComplexViewModel(value: value, subErrors: subErrors, expanded: nil, root: nil)
        self.init(
            viewModel: viewModel,
            errors: errors,
            label: label,
            fields: fields
        ) {
            AttributeView<Config>(
                attribute: viewModel.attributes[$0]?.value ?? .constant(.bool(false)),
                errors: viewModel.errorBinding(forAttribute: $0),
                subErrors: viewModel.subErrors(forAttribute: $0),
                label: $1,
                delayEdits: delayEdits
            )
        }
    }
    
    private init(viewModel: ComplexViewModel, errors: Binding<[String]>, label: String, fields: [Field], subView: @escaping (String, String)-> AttributeView<Config>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._errors = errors
        self.label = label
        self.fields = fields
        self.subView = subView
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
                                    if let binding = viewModel.expandedBinding(field.name) {
                                        DisclosureGroup(field.name.pretty, isExpanded: binding) {
                                            subView(field.name, "")
                                        }
                                    } else {
                                        DisclosureGroup(field.name.pretty) {
                                            subView(field.name, "")
                                        }
                                    }
                                } else {
                                    subView(field.name, field.name.pretty)
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
        
        @State var expanded: [AnyKeyPath: Bool] = [:]
        
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
                fields: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)],
                expanded: $expanded
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
