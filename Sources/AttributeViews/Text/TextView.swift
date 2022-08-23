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

/// A view that displays and allows editing of a text property.
public struct TextView: View {

    /// A binding to the value of the text property.
    @Binding var value: String

    /// A binding to the errors associated with the text property.
    @Binding var errors: [String]

    /// The label associated with the text property.
    let label: String

    /// An optional function to execute when editing has completed.
    let onCommit: ((String) -> Void)?

    /// Create a new `TextView`.
    /// 
    /// This initialiser create a new `TextView` utilising a key
    /// path from a `Modifiable` object that contains the text property
    /// that this view is associated with.
    /// 
    /// - Parameter root: A binding to the base `Modifiable` object that
    /// contains the text property that this view is associated
    /// with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the text
    /// property from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to place within a `TextField` when
    /// presenting the text property.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, String>,
        label: String,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? "" : root.wrappedValue[keyPath: path.keyPath] },
                set: { _ in }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label
        ) {
            let result = root.wrappedValue.modify(attribute: path, value: $0)
            switch result {
            case .success(true), .failure:
                notifier?.send()
            default:
                return
            }
        }
    }

    /// Create a new `TextView`.
    /// 
    /// This initialiser create a new `TextView` utilising a
    /// binding to the text property directly. It is useful to call
    /// this initialiser when utilising text properties that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter value: A binding to the text property that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors associated with
    /// the text property.
    /// 
    /// - Parameter label: The label to place within a `TextField` when
    /// presenting the text property.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    public init(
        value: Binding<String>,
        errors: Binding<[String]> = .constant([]),
        label: String,
        delayEdits: Bool = false
    ) {
        self.init(
            value: value,
            errors: errors,
            label: label,
            onCommit: delayEdits ? { value.wrappedValue = $0 } : nil
        )
    }

    /// Create a new `TextView`.
    /// 
    /// - Parameter value: A binding to the text property that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors associated with
    /// the text property.
    /// 
    /// - Parameter label: The label to use when presenting the text property.
    /// 
    /// - Parameter onCommit: An optional function that is executed when
    /// editing has been completed.
    private init(
        value: Binding<String>,
        errors: Binding<[String]>,
        label: String,
        onCommit: ((String) -> Void)?
    ) {
        self._value = value
        self._errors = errors
        self.label = label
        self.onCommit = onCommit
    }

    /// The contents of this view.
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
            ForEach(errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            Group {
                GeometryReader { geometry in
                    Editor(editingText: $value, size: geometry.size, onCommit: onCommit)
                        .focusable()
                }.clipShape(RoundedRectangle(cornerRadius: 5))
            }.overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }

}

#if canImport(SwiftUI)

/// Previews associated with `TextView`.
struct TextView_Previews: PreviewProvider {

    /// A view that creates a `TextView` from a `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object that contains the text property.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "text", type: .text)],
                attributes: ["text": .text("some text\non different lines")],
                metaData: [:]
            )
        ])

        /// The path to the text property within `modifiable`.
        let path = EmptyModifiable.path.attributes[0].attributes["text"].wrappedValue.textValue

        /// The contents of this view.
        var body: some View {
            TextView(
                root: $modifiable,
                path: path,
                label: "Root"
            )
        }

    }

    /// A view that creates a `TextView` utilising a binding to the text
    /// property directly.
    struct Binding_Preview: View {

        /// The value of the text property.
        @State var value: String = "More text\non separate lines"

        /// Errors associated with the text property.
        @State var errors: [String] = ["An error", "A second error"]

        /// The contents of this view.
        var body: some View {
            TextView(value: $value, errors: $errors, label: "Binding")
        }

    }

    /// All previews associated with `TextView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}
#endif
