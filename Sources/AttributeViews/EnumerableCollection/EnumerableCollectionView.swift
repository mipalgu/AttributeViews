//
//  EnumerableCollectionView.swift
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

// swiftlint:disable type_contents_order

/// A view that displays a collection of enumerated properties.
/// 
/// The view creates a grid containing that contains a `Toggle` for each
/// possible value within the collection. Thus, the user may toggle each value
/// within the collection. Errors are displayed below the label.
public struct EnumerableCollectionView: View {

    /// The set of values that have been selected.
    @Binding var value: Set<String>

    /// The errors associated with the enumerated property.
    @Binding var errors: [String]

    /// The label to display above the grid.
    let label: String

    /// The set of all values to choose from.
    let validValues: Set<String>

    /// Create a new `EnumerableCollectionView`.
    /// 
    /// This initialiser create a new `EnumerableCollectionView` utilising a key
    /// path from a `Modifiable` object that contains the enumerable collection
    /// that this view is associated with.
    /// 
    /// - Parameter root: A reference to the base `Modifiable` object that
    /// contains the enumerable collection that this view is associated with.
    /// 
    /// - Parameter path: A `Attributes.Path` that points to the enumerable
    /// collection from the base `Modifiable` object.
    /// 
    /// - Parameter label: The label to use when displaying the enumerable
    /// collection.
    /// 
    /// - Parameter validValues: The set of all values to choose from.
    /// 
    /// - Parameter notifier: A `GlobalChangeNotifier` that will be used to
    /// notify any listeners when a trigger is fired.
    public init<Root: Modifiable>(
        root: Binding<Root>,
        path: Attributes.Path<Root, Set<String>>,
        label: String,
        validValues: Set<String>,
        notifier: GlobalChangeNotifier? = nil
    ) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? [] : root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    let result = root.wrappedValue.modify(attribute: path, value: $0)
                    switch result {
                    case .success(true), .failure:
                        notifier?.send()
                    default:
                        return
                    }
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map(\.message) },
                set: { _ in }
            ),
            label: label,
            validValues: validValues
        )
    }

    /// Create a new `EnumerableCollectionView`.
    /// 
    /// This initialiser create a new `EnumerableCollectionView` utilising a
    /// binding to the enumerable collection directly. It is useful to call this
    /// initialiser when utilising enumerable collections that do not exist
    /// within a `Modifiable` object.
    /// 
    /// - Parameter value: A binding to the enumerable collection that this
    /// view is associated with.
    /// 
    /// - Parameter errors: A binding to the errors that will be displayed.
    /// 
    /// - Parameter label: The label to use when displaying the enumerable
    /// collection.
    /// 
    /// - Parameter validValues: The set of all values to choose from.
    public init(
        value: Binding<Set<String>>,
        errors: Binding<[String]> = .constant([]),
        label: String,
        validValues: Set<String>
    ) {
        self._value = value
        self._errors = errors
        self.label = label
        self.validValues = validValues
    }

    /// The contents of this view.
    public var body: some View {
        // swiftlint:disable:next closure_body_length
        VStack(alignment: .leading) {
            Text(label + ":").fontWeight(.bold)
            VStack {
                ForEach(errors, id: \.self) { error in
                    Text(error).foregroundColor(.red)
                }
            }
            if validValues.isEmpty {
                HStack {
                    Spacer()
                    Text("There are currently no values.")
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(
                        .adaptive(minimum: 100, maximum: .infinity),
                        spacing: 10,
                        alignment: .topLeading
                    )
                ]) {
                    ForEach(validValues.sorted(), id: \.self) { element in
                        Toggle(element, isOn: Binding(
                            get: { value.contains(element) },
                            set: { isChecked in
                                if isChecked {
                                    value.insert(element)
                                } else {
                                    value.remove(element)
                                }
                            }
                        )).focusable()
                    }
                }
            }
        }
    }

}

#if canImport(SwiftUI)

/// The previews for `EnumerableCollectionView`.
struct EnumerableCollectionView_Previews: PreviewProvider {

    /// A view that displays an `EnumerableCollectionView` initialised utilising
    /// a `Modifiable` object.
    struct Root_Preview: View {

        /// The `Modifiable` object containing the enumerable collection.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "enumerableCollection",
                        type: .enumerableCollection(validValues: ["a", "b", "c", "d", "e", "f"])
                    )
                ],
                attributes: [
                    "enumerableCollection": .enumerableCollection(
                        ["a", "b", "e", "f"],
                        validValues: ["a", "b", "c", "d", "e", "f"]
                    )
                ],
                metaData: [:]
            )
        ])

        /// The path to the enumerable collection within `modifiable`.
        let path = EmptyModifiable
            .path
            .attributes[0]
            .attributes["enumerableCollection"]
            .wrappedValue
            .enumerableCollectionValue

        /// The contents of the view.
        var body: some View {
            EnumerableCollectionView(
                root: $modifiable,
                path: path,
                label: "Root",
                validValues: ["a", "b", "c", "d", "e", "f"]
            )
        }

    }

    /// A view that displays an `EnumerableCollectionView` initialised utilising
    /// a binding to the enumerable collection directly.
    struct Binding_Preview: View {

        /// The set of selected values.
        @State var value: Set<String> = ["A", "D", "F"]

        /// The errors associated with the enumerable collection.
        @State var errors: [String] = ["An error", "A second error"]

        /// The contents of the view.
        var body: some View {
            EnumerableCollectionView(
                value: $value,
                errors: $errors,
                label: "Binding",
                validValues: ["A", "B", "C", "D", "E", "F"]
            )
        }

    }

    /// All previews of `EnumerableCollectionView`.
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }

}

#endif
