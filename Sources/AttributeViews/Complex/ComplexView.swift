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

// swiftlint:disable type_contents_order

/// A view the displays a complex property.
/// 
/// The view creates a `Seciton` containing disclosure groups for each
/// sub-attribute. The view delegates the display of each sub-attribute to
/// `AttributeView`, and simply places each `AttributeView` within a collapsable
/// disclosure group.
public struct ComplexView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: ComplexViewModel

    /// Create a new `ComplexView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: ComplexViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
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
                                    DisclosureGroup(
                                        field.name.pretty,
                                        isExpanded: viewModel.expandedBinding(field.name)
                                    ) {
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

#if canImport(SwiftUI)

/// The previews associated with `ComplexView`.
struct ComplexView_Previews: PreviewProvider {

    /// A view that creates a `ComplexView` utilising a `Modifiable` object.
    struct Root_Preview: View {

        /// A dictionary indicating which attributes are expanded.
        @State var expanded: [AnyKeyPath: Bool] = [:]

        /// A reference to a `Modifiable` object that contains the complex
        /// property.
        @State var modifiable: Ref<EmptyModifiable> = Ref(copying: EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "complex",
                        type: .complex(
                            layout: [
                                Field(name: "bool", type: .bool),
                                Field(name: "integer", type: .integer)
                            ]
                        )
                    )
                ],
                attributes: [
                    "complex": .complex(
                        ["bool": .bool(false), "integer": .integer(3)],
                        layout: [
                            Field(name: "bool", type: .bool),
                            Field(name: "integer", type: .integer)
                        ]
                    )
                ],
                metaData: [:]
            )
        ]))

        /// A path to the complex property within `modifiable`.
        let path = EmptyModifiable.path.attributes[0].attributes["complex"].wrappedValue.complexValue

        /// The contents of this view.
        var body: some View {
            ComplexViewPreview(
                viewModel: ComplexViewModel(
                    root: modifiable,
                    path: path,
                    label: "Root",
                    fieldsPath: EmptyModifiable
                        .path
                        .attributes[0]
                        .attributes["complex"]
                        .wrappedValue
                        .complexFields
                )
            )
        }

    }

    /// A view that creates a `ComplexView` utilising a binding to the complex
    /// property directly.
    struct Binding_Preview: View {

        /// The value of the complex property.
        @State var value: [String: Attribute] = [
            "s": .line("Hello"),
            "f": .float(3.12)
        ]

        /// Errors associated with the complex property.
        @State var errors: [String] = ["An error", "A second error"]

        /// The contents of this view.
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

    /// A view that creates a @StateObject `ComplexViewModel` that gets passed
    /// to a `ComplexView`.
    struct ComplexViewPreview: View {

        /// The view model associated with the `ComplexView`.
        @StateObject var viewModel: ComplexViewModel

        /// Create a new `ComplexView`, passing `viewModel` to it.
        var body: some View {
            ComplexView(viewModel: viewModel)
        }

    }

    /// All previews associated with `ComplexView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}

#endif
