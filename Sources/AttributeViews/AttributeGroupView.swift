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

final class AttributeGroupViewModel: ObservableObject {
    
    let value: Binding<AttributeGroup>
    
    private var attributesViewModels: [String: AttributeViewModel] = [:]
    
    public var attributes: [String: AttributeViewModel] {
        get {
            Dictionary(uniqueKeysWithValues: value.wrappedValue.attributes.keys.map { key in
                if let viewModel = attributesViewModels[key] {
                    return (key, viewModel)
                }
                let viewModel = AttributeViewModel(
                    value: Binding(
                        get: { self.value.wrappedValue.attributes[key] ?? .bool(false) },
                        set: { self.value.wrappedValue.attributes[key] = $0 }
                    )
                )
                attributesViewModels[key] = viewModel
                return (key, viewModel)
            })
        } set {
            value.wrappedValue.attributes = newValue.mapValues {
                $0.value.wrappedValue
            }
            objectWillChange.send()
        }
    }
    
    init(value: Binding<AttributeGroup>) {
        self.value = value
    }
    
}

final class AttributeViewModel: ObservableObject {
    
    let value: Binding<Attribute>
    
    var attribute: Attribute {
        get {
            value.wrappedValue
        } set {
            value.wrappedValue = newValue
            objectWillChange.send()
        }
    }
    
    var blockAttribute: BlockAttribute {
        get {
            value.wrappedValue.blockAttribute
        } set {
            value.wrappedValue.blockAttribute = newValue
            objectWillChange.send()
        }
    }
    
    var lineAttribute: LineAttribute {
        get {
            value.wrappedValue.lineAttribute
        } set {
            value.wrappedValue.lineAttribute = newValue
            objectWillChange.send()
        }
    }
    
    init(value: Binding<Attribute>) {
        self.value = value
    }
    
}

public struct AttributeGroupView<Config: AttributeViewConfig>: View {
    
    @StateObject var viewModel: AttributeGroupViewModel
    let label: String
    let subView: (String, String) -> AttributeView<Config>
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        let viewModel = AttributeGroupViewModel(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? AttributeGroup(name: "") : root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = root.wrappedValue.modify(attribute: path, value: $0)
                }
            )
        )
        self.init(viewModel: viewModel, label: label) { (field, label) in
            AttributeView(attribute: viewModel.attributes[field]?.value ?? .constant(.bool(false)), label: label)
        }
    }
    
    private init(viewModel: AttributeGroupViewModel, label: String, subView: @escaping (String, String) -> AttributeView<Config>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self.subView = subView
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        if !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(label.pretty).font(.title3)
                            Divider()
                        }
                        ForEach(viewModel.value.wrappedValue.fields, id: \.name) { field in
                            if let attribute = viewModel.attributes[field.name] {
                                if attribute.value.wrappedValue.isBlock == true {
                                    DisclosureGroup(field.name.pretty) {
                                        subView(field.name, "")
                                    }
                                } else {
                                    subView(field.name, field.name.pretty)
                                    Spacer()
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
}

struct AttributeGroupView_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0]
        
        let config = DefaultAttributeViewsConfig()
        
        var body: some View {
            AttributeGroupView<DefaultAttributeViewsConfig>(
                root: $modifiable,
                path: path,
                label: "Root"
            ).environmentObject(config)
        }
        
    }
    
//    struct Binding_Preview: View {
//
//        @State var value: AttributeGroup = AttributeGroup(
//            name: "Binding",
//            fields: [Field(name: "s", type: .line)],
//            attributes: ["s": .line("Hello")],
//            metaData: [:]
//        )
//
//        let config = DefaultAttributeViewsConfig()
//
//        var body: some View {
//            AttributeGroupView<DefaultAttributeViewsConfig>(value: $value, label: "Binding").environmentObject(config)
//        }
//
//    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
//            Binding_Preview()
        }
    }
}
