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

public struct EnumerableCollectionView: View {

    @Binding var value: Set<String>
    @Binding var errors: [String]

    let label: String
    let validValues: Set<String>

    //@EnvironmentObject var config: Config

    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Set<String>>, label: String, validValues: Set<String>, notifier: GlobalChangeNotifier? = nil) {
        self.init(
            value: Binding(
                get: { path.isNil(root.wrappedValue) ? [] : root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    let result = root.wrappedValue.modify(attribute: path, value: $0)
                    switch result {
                    case .success(true), .failure:
                        notifier?.send()
                    default: return
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

    public init(value: Binding<Set<String>>, errors: Binding<[String]> = .constant([]), label: String, validValues: Set<String>) {
        self._value = value
        self._errors = errors
        self.label = label
        self.validValues = validValues
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(label + ":")
//                .font(config.fontHeading)
                .fontWeight(.bold)
            if validValues.isEmpty {
                HStack {
                    Spacer()
                    Text("There are currently no values.")
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 10, alignment: .topLeading)]) {
                    ForEach(validValues.sorted(), id: \.self) { element in
                        Toggle(element, isOn: Binding(
                            get: { value.contains(element) },
                            set: { (isChecked) in
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
struct EnumerableCollectionView_Previews: PreviewProvider {

    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "enumerableCollection", type: .enumerableCollection(validValues: ["a", "b", "c", "d", "e", "f"]))], attributes: ["enumerableCollection": .enumerableCollection(["a", "b", "e", "f"], validValues: ["a", "b", "c", "d", "e", "f"])], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["enumerableCollection"].wrappedValue.enumerableCollectionValue
        
        var body: some View {
            EnumerableCollectionView(
                root: $modifiable,
                path: path,
                label: "Root",
                validValues: ["a", "b", "c", "d", "e", "f"]
            )
        }
        
    }

    struct Binding_Preview: View {
        
        @State var value: Set<String> = ["A", "D", "F"]
        @State var errors: [String] = ["An error", "A second error"]
        
        var body: some View {
            EnumerableCollectionView(
                value: $value,
                errors: $errors,
                label: "Binding",
                validValues: ["A", "B", "C", "D", "E", "F"]
            )
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
