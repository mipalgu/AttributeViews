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

// swiftlint:disable type_contents_order

/// A view that displays and edits a line property.
/// 
/// The view displays a `TextField` that allows a user to edit the value of the
/// line property and presents the errors associated with those edits below
/// the text field.
public struct LineView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: LineViewModel

    /// Create a new `LineView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: LineViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(
                viewModel.label,
                text: $viewModel.editingValue,
                onEditingChanged: viewModel.onEditingChanged
            )
            .font(.body)
            .focusable()
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

import GUUI

#if canImport(SwiftUI)

/// All previews associated with `LineView`.
struct LineView_Previews: PreviewProvider {

    /// Creates a `LineView` utilising a line property that exists within a
    /// `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object that contains the line property being
        /// displayed.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "line", type: .line)],
                attributes: ["line": .line("hello")],
                metaData: [:]
            )
        ])

        /// The path to the line property value.
        let path = EmptyModifiable.path.attributes[0].attributes["line"].wrappedValue.lineValue

        /// The contents of the preview, creating a `LineViewModel` utilising
        /// the `LineViewModel(root:path:label:)` initialiser.
        var body: some View {
            LineViewPreviewView(
                viewModel: LineViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Root"
                )
            )
        }

    }

    /// Creates a `LineView` utilising a line property that does not exist
    /// within a `Modifiable` object.
    struct Binding_Preview: View {

        /// The `LineViewModel` initialised using
        /// `LineViewModel(valueRef:errorsRef:label:)`.
        @StateObject var viewModel = LineViewModel(
            valueRef: Ref(copying: "world"),
            errorsRef: ConstRef { ["An error", "A second error"] },
            label: "Binding"
        )

        /// The `LineView`, initialised with `viewModel`.
        var body: some View {
            LineView(viewModel: viewModel)
        }

    }

    /// A view that creates a @StateObject `LineViewModel` that it passes to
    /// `LineView`.
    struct LineViewPreviewView: View {

        /// The view model associated with this view.
        @StateObject var viewModel: LineViewModel

        /// Create a new `LineView`, passing in `viewModel`.
        var body: some View {
            LineView(viewModel: viewModel)
        }

    }

    /// All previews associated with `LineView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}
#endif
