//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes

public struct BoolView: View {

    @ObservedObject var viewModel: BoolViewModel

    public init(viewModel: BoolViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Toggle(viewModel.label, isOn: $viewModel.value)
                .animation(.easeOut)
                .font(.body)
                .focusable()
//                .foregroundColor(config.textColor)
            ForEach(viewModel.errors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
        }
    }
}

import GUUI

#if canImport(SwiftUI)
struct BoolView_Previews: PreviewProvider {

    struct Root_Preview: View {

        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [Field(name: "bool", type: .bool)],
                attributes: ["bool": .bool(false)],
                metaData: [:]
            )
        ])

        let path = EmptyModifiable.path.attributes[0].attributes["bool"].wrappedValue.boolValue

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

    struct Binding_Preview: View {

        @State var value: Bool = false

        @State var errors: [String] = ["An Error."]

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

    struct BoolPreviewView: View {

        @StateObject var viewModel: BoolViewModel

        var body: some View {
            BoolView(viewModel: viewModel)
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

