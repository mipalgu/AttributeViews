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
import GUUI

final class ComplexValue: Value<[String: Attribute]> {
    
    private let _viewModel: (String) -> AttributeViewModel
    
    override init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, notifier: GlobalChangeNotifier? = nil) {
        self._viewModel = { AttributeViewModel(root: root, path: path[$0].wrappedValue, label: $0, notifier: notifier) }
        super.init(root: root, path: path, notifier: notifier)
    }
    
    init(valueRef: Ref<[String: Attribute]>, errorsRef: ConstRef<[String]>, delayEdits: Bool) {
        self._viewModel = { AttributeViewModel(valueRef: valueRef[$0].wrappedValue, errorsRef: ConstRef(copying: []), label: $0, delayEdits: delayEdits) }
        super.init(valueRef: valueRef, errorsRef: errorsRef)
    }
    
    func viewModel(forAttribute attribute: String) -> AttributeViewModel {
        self._viewModel(attribute)
    }
    
}

public final class ComplexViewModel: ObservableObject, GlobalChangeNotifier {
    
    private let ref: ComplexValue
    
    private var expanded: [String: Bool] = [:]
    
    private var attributeViewModels: [String: AttributeViewModel] = [:]
    
    @Published public var label: String
    
    @Published public var fields: [Field]
    
    var errors: [String] {
        ref.errors
    }
    
    init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, [String: Attribute]>, label: String, fields: [Field], notifier: GlobalChangeNotifier? = nil) {
        self.ref = ComplexValue(root: root, path: path, notifier: notifier)
        self.label = label
        self.fields = fields
    }
    
    init(valueRef: Ref<[String: Attribute]>, errorsRef: ConstRef<[String]> = ConstRef(copying: []), label: String, fields: [Field], delayEdits: Bool = false) {
        self.ref = ComplexValue(valueRef: valueRef, errorsRef: errorsRef, delayEdits: delayEdits)
        self.label = label
        self.fields = fields
    }
    
    func expandedBinding(_ fieldName: String) -> Binding<Bool> {
        return Binding(
            get: { self.expanded[fieldName] ?? false },
            set: { self.expanded[fieldName] = $0 }
        )
    }
    
    public func send() {
        self.attributeViewModels.values.forEach {
            $0.send()
        }
        objectWillChange.send()
    }
    
    func viewModel(forField fieldName: String) -> AttributeViewModel {
        if let viewModel = attributeViewModels[fieldName] {
            return viewModel
        }
        let viewModel = ref.viewModel(forAttribute: fieldName)
        attributeViewModels[fieldName] = viewModel
        return viewModel
    }
    
}

public struct ComplexView: View {
    
    @ObservedObject var viewModel: ComplexViewModel
    
    //@EnvironmentObject var config: Config
    
    public init(viewModel: ComplexViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if !viewModel.fields.isEmpty {
                Section(header: HStack {
                    Text(viewModel.label.pretty).font(.headline)
                    Spacer()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.fields, id: \.name) { field in
                                if viewModel.viewModel(forField: field.name).attribute.isBlock {
                                    DisclosureGroup(field.name.pretty, isExpanded: viewModel.expandedBinding(field.name)) {
                                        //AttributeView(viewModel: viewModel.viewModel(forField: field.name))
                                        Text(field.name)
                                    }
                                } else {
                                    //AttributeView(viewModel: viewModel.viewModel(forField: field.name))
                                    Text(field.name)
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
        
        @State var modifiable: Ref<EmptyModifiable> = Ref(copying: EmptyModifiable(attributes: [
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
        ]))
        
        let path = EmptyModifiable.path.attributes[0].attributes["complex"].wrappedValue.complexValue
        
        var body: some View {
            ComplexViewPreview(
                viewModel: ComplexViewModel(
                    root: modifiable,
                    path: path,
                    label: "Root",
                    fields: [Field(name: "bool", type: .bool), Field(name: "integer", type: .integer)]
                )
            )
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: [String: Attribute] = [
            "s": .line("Hello"),
            "f": .float(3.12)
        ]
        @State var errors: [String] = ["An error", "A second error"]
        
        var body: some View {
            ComplexViewPreview(
                viewModel: ComplexViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef { self.errors },
                    label: "Binding",
                    fields: ["s": .line, "f": .float]
                )
            )
        }
        
    }
    
    struct ComplexViewPreview: View {
        
        @StateObject var viewModel: ComplexViewModel
        
        var body: some View {
            ComplexView(viewModel: viewModel)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
