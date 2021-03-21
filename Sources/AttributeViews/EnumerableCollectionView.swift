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

public struct EnumerableCollectionView<Config: AttributeViewConfig>: View {
    
    @Binding var value: Set<String>
    @State var errors: [String]
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Set<String>>, label: String, validValues: Set<String>) {
        let errors = State<[String]>(initialValue: root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message })
        self._errors = errors
        self._value = Binding(
            get: { root.wrappedValue[keyPath: path.keyPath] },
            set: {
                _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                errors.wrappedValue = root.wrappedValue.errorBag.errors(forPath: AnyPath(path)).map { $0.message }
            }
        )
        self.label = label
        self.validValues = validValues
    }
    
    init(value: Binding<Set<String>>, label: String, validValues: Set<String>) {
        self._value = value
        self._errors = State<[String]>(initialValue: [])
        self.label = label
        self.validValues = validValues
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label + ":").font(config.fontHeading).fontWeight(.bold)
            if validValues.isEmpty {
                HStack {
                    Spacer()
                    Text("There are currently no values.")
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 10, alignment: .topLeading)]) {
                    ForEach(Array(validValues.sorted()), id: \.self) { element in
                        Toggle(element, isOn: Binding(
                            get: { value.contains(element) },
                            set: { (isChecked) in
                                if isChecked {
                                    value.insert(element)
                                } else {
                                    value.remove(element)
                                }
                            }
                        ))
                    }
                }
            }
        }
    }
}
