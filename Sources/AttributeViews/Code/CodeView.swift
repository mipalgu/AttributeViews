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

/// A view that displays an editor capable of editing source code.
/// 
/// The view is split into two distinct parts, the header and the editor. The
/// header displays the label of the view and any errors associated with the
/// input. The editor is an `Editor` that handles the user input and source
/// code manipulation.
public struct CodeView<Label: View>: View {

    /// A binding to the source code.
    @Binding var value: Code

    /// A binding to any errors associated with `value`.
    @Binding var errors: [String]

    /// A function that returns the label associated with this view.
    let label: () -> Label

    /// The language that the source code is written in.
    let language: Language

    /// A function to execute when editing has completed.
    let onCommit: ((Code) -> Void)?

    /// Create a new `CodeView`.
    /// 
    /// This initialiser create a new `CodeView` utilising a key
    /// path from a `Modifiable` object that contains the code property
    /// that this view is associated with.
    /// 
    /// - Parameter root: A binding to the base `Modifiable` object that
    /// contains the code property that this view is associated
    /// with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the code
    /// property from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to place within a `TextField` when
    /// presenting the code property.
    /// 
    /// - Parameter language: The language that the source code is written in.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, Code>,
        label: String,
        language: Language,
        notifier: GlobalChangeNotifier? = nil
    ) where Label == Text {
        self.init(root: root, path: path, language: language, notifier: notifier) {
            Text(label.capitalized)
        }
    }

    /// Create a new `CodeView`.
    /// 
    /// This initialiser create a new `CodeView` utilising a
    /// binding to the code property directly. It is useful to call
    /// this initialiser when utilising code properties that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter value: A binding to the code property that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors associated with
    /// the code property.
    /// 
    /// - Parameter label: The label to place within a `TextField` when
    /// presenting the code property.
    /// 
    /// - Parameter language: The language that the source code is written in.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    public init(
        value: Binding<Code>,
        errors: Binding<[String]> = .constant([]),
        label: String,
        language: Language,
        delayEdits: Bool = false
    ) where Label == Text {
        self.init(value: value, errors: errors, language: language, delayEdits: delayEdits) {
            Text(label.capitalized)
        }
    }

    /// Create a new `CodeView`.
    /// 
    /// This initialiser create a new `CodeView` utilising a key
    /// path from a `Modifiable` object that contains the code property
    /// that this view is associated with.
    /// 
    /// - Parameter root: A binding to the base `Modifiable` object that
    /// contains the code property that this view is associated
    /// with.
    /// 
    /// - Parameter path: An `Attributes.Path` that points to the code
    /// property from the base `Modifiable` object.
    /// 
    /// - Parameter language: The language that the source code is written in.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    /// 
    /// - Parameter label: The label to use when presenting the code property.
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, Code>,
        language: Language,
        notifier: GlobalChangeNotifier? = nil,
        label: @escaping () -> Label
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
            language: language,
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

    /// Create a new `CodeView`.
    /// 
    /// This initialiser create a new `CodeView` utilising a
    /// binding to the code property directly. It is useful to call
    /// this initialiser when utilising code properties that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter value: A binding to the code property that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors associated with
    /// the code property.
    /// 
    /// - Parameter language: The language that the source code is written in.
    /// 
    /// - Parameter delayEdits: Delays edit notifications for those attributes
    /// where it is applicable to do so (for example, delaying edits for a
    /// `LineAttribute` so that a notification is not sent for every
    /// character change).
    /// 
    /// - Parameter label: The label to use when presenting the code property.
    public init(
        value: Binding<Code>,
        errors: Binding<[String]> = .constant([]),
        language: Language,
        delayEdits: Bool = false,
        label: @escaping () -> Label
    ) {
        self.init(
            value: value,
            errors: errors,
            language: language,
            label: label,
            onCommit: delayEdits ? { value.wrappedValue = $0 } : nil
        )
    }

    /// Create a new `CodeView`.
    /// 
    /// - Parameter value: A binding to the code property that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors associated with
    /// the code property.
    /// 
    /// - Parameter language: The language that the source code is written in.
    /// 
    /// - Parameter label: The label to use when presenting the code property.
    /// 
    /// - Parameter onCommit: An optional function that is executed when
    /// editing has been completed.
    private init(
        value: Binding<Code>,
        errors: Binding<[String]> = .constant([]),
        language: Language,
        label: @escaping () -> Label,
        onCommit: ((Code) -> Void)?
    ) {
        self._value = value
        self._errors = errors
        self.label = label
        self.language = language
        self.onCommit = onCommit
    }

    /// The contents of thie view.
    public var body: some View {
        VStack(alignment: .leading) {
            label()
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
            .frame(minHeight: 80)
        }
    }

}

#if canImport(SwiftUI)

/// The previews associated with `CodeView`.
struct CodeView_Previews: PreviewProvider {

    /// A view that creates a `CodeView` from a `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object containing the code property.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(name: "code", type: .code(language: .swift))
                ],
                attributes: ["code": .code("let i = 2\nletb = true", language: .swift)],
                metaData: [:]
            )
        ])

        /// The path to the code property within `modifiable`.
        let path = EmptyModifiable.path.attributes[0].attributes["code"].wrappedValue.codeValue

        /// The contents of the view.
        var body: some View {
            CodeView(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift
            )
        }

    }

    /// A view that creates a `CodeView` utilising a binding to the code
    /// property directly.
    struct Binding_Preview: View {

        /// The value of the code property.
        @State var value: String = "let f = 2.3\nlet s = \"hello\""

        /// Errors associated with the code property.
        @State var errors: [String] = ["An error", "A second error"]

        /// The contents of the view.
        var body: some View {
            CodeView(value: $value, errors: $errors, label: "Binding", language: .swift)
        }

    }

    /// All previews associated with `CodeView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}
#endif
