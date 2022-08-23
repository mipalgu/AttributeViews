//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
/// Tokamak doesn't have a Form, typealias it to VStack.
typealias Form = VStack
#else
import SwiftUI
#endif

import Attributes
import GUUI

// swiftlint:disable type_contents_order

/// A view that displays a single `AttributeGroup`.
/// 
/// The view takes the form of a `ComplexView` within a
/// scrollable `Form`. Therefore, the main content of this view is delegated
/// to a single `ComplexView` that displays all attributes within the
/// group.
public struct AttributeGroupView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: AttributeGroupViewModel

    /// Create a new `AttributeGroupView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: AttributeGroupViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The main content of this view.
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                ComplexView(viewModel: viewModel.complexViewModel)
            }
        }
    }

}

#if canImport(SwiftUI)

/// The preview view for the `AttributeGroupView`.
struct AttributeGroupView_Previews: PreviewProvider {

    /// A view that contains a `Modifiable` object utilised to test the view
    /// when using the functionality from a `Modifiable` object.
    struct Root_Preview: View {

        /// The @State property that contains a base `Modifiable` object
        /// containing attribute groups.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "float", type: .float)],
                attributes: ["float": .float(0.1)],
                metaData: [:]
            )
        ])

        /// A key path to the attribute group we are displaying.
        let path = EmptyModifiable.path.attributes[0]

        /// The content of the preview.
        var body: some View {
            AttributeGroupPreviewView(
                viewModel: AttributeGroupViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path
                )
            )
        }

    }

    /// A view that contains the root @StateObject view model.
    struct AttributeGroupPreviewView: View {

        /// The view model associated with the `AttributeGroupView`.
        @StateObject var viewModel: AttributeGroupViewModel

        /// Create a new `AttributeGroupView`, passing in the view model.
        var body: some View {
            AttributeGroupView(viewModel: viewModel)
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
//            AttributeGroupView<DefaultAttributeViewsConfig>(value: $value, label: "Binding")
//              .environmentObject(config)
//        }
//
//    }

    /// The previews.
    static var previews: some View {
        VStack {
            Root_Preview()
//            Binding_Preview()
        }
    }
}

#endif
