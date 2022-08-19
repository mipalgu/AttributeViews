//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

import Attributes
import GUUI
import TokamakShim

// swiftlint:disable type_contents_order

/// The view for displaying boolean attributes.
/// 
/// A boolean attribute is displayed as a toggle button with its associated
/// label. Any errors associated with the attribute are displayed vertifcally
/// below the toggle switch.
public struct BoolView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: BoolViewModel

    /// Create a new `BoolView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: BoolViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The content of the view.
    public var body: some View {
        VStack(alignment: .leading) {
            #if canImport(SwiftUI)
            Toggle(viewModel.label, isOn: $viewModel.value)
                .animation(.easeOut)
                .font(.body)
                .focusable()
            #else
            Toggle(viewModel.label, isOn: $viewModel.value)
                .font(.body)
                .focusable()
            #endif
//                .foregroundColor(config.textColor)
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }

}

#if canImport(SwiftUI)

/// Preview for `BoolView`.`
struct BoolView_Previews: PreviewProvider {

    /// A view for previewing the operation of `BoolView` when utilising an
    /// attribute within a `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object containing bool attributes.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "bool", type: .bool)],
                attributes: ["bool": .bool(false)],
                metaData: [:]
            )
        ])

        /// A path to the attribute being displayed within `modifiable`.
        let path = EmptyModifiable.path.attributes[0].attributes["bool"].wrappedValue.boolValue

        /// The content of the view.
        var body: some View {
            BoolPreviewView(
                viewModel: BoolViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Root"
                )
            )
        }

    }

    /// A view for previewing the operation of `BoolView` when utilising a
    /// reference directly to a bool attribute.
    struct Binding_Preview: View {

        /// The bool being displayed.
        @State var value = false

        /// Errors associated with `value`.
        @State var errors: [String] = ["An Error."]

        /// The content of the view.
        var body: some View {
            BoolPreviewView(
                viewModel: BoolViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef { self.errors },
                    label: "Binding"
                )
            )
        }

    }

    /// A view for creating the base @StateObject view model for the `BoolView`.
    struct BoolPreviewView: View {

        /// The view model associated with the `BoolView`.
        @StateObject var viewModel: BoolViewModel

        /// Create a new `BoolView`, utilising `viewModel` as the associated
        /// view model for the view.
        var body: some View {
            BoolView(viewModel: viewModel)
        }

    }

    /// All previews.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}

#endif
