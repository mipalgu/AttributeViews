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

public struct AttributeGroupView<Config: AttributeViewConfig, Root: Modifiable>: View {

    @Binding var root: Root
    let path: Attributes.Path<Root, AttributeGroup>
    let label: String
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, AttributeGroup>, label: String) {
        self._root = root
        self.path = path
        self.label = label
    }
    
    @ViewBuilder
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(root[keyPath: path.keyPath].fields, id: \.name) { field in
                            AttributeView<Config, Root>(
                                root: $root,
                                path: path.attributes[field.name].wrappedValue,
                                label: field.name.pretty
                            )
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
}

import Machines

struct AttributeGroupView_Previews: PreviewProvider {
    
    struct AttributeGroupViewRoot_Preview: View {

        @State var machine: Machine = Machine.initialSwiftMachine()

        let config = DefaultAttributeViewsConfig()

        let path = Machine.path.attributes[0]

        var body: some View {
            AttributeGroupView<DefaultAttributeViewsConfig, Machine>(root: $machine, path: path, label: "Variables").environmentObject(config)
        }

    }
    
    static var previews: some View {
        VStack {
            AttributeGroupViewRoot_Preview()
        }
    }
}
