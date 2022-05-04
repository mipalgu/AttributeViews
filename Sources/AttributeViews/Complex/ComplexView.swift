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
                                        AttributeView(viewModel: viewModel.viewModel(forField: field.name))
                                    }
                                } else {
                                    AttributeView(viewModel: viewModel.viewModel(forField: field.name))
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

import GUUI

#if canImport(SwiftUI)
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
                    fieldsPath: EmptyModifiable.path.attributes[0].attributes["complex"].wrappedValue.complexFields
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
#endif
