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

public struct LineView: View {

    @ObservedObject var viewModel: LineViewModel

    public init(viewModel: LineViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading) {
            TextField(viewModel.label, text: $viewModel.editingValue, onEditingChanged: viewModel.onEditingChanged)
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
struct LineView_Previews: PreviewProvider {

    struct Root_Preview: View {

        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "line", type: .line)], attributes: ["line": .line("hello")], metaData: [:])
        ])

        let path = EmptyModifiable.path.attributes[0].attributes["line"].wrappedValue.lineValue

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

    struct Binding_Preview: View {

        @StateObject var viewModel: LineViewModel = LineViewModel(valueRef: Ref(copying: "world"), errorsRef: ConstRef { ["An error", "A second error"] }, label: "Binding")

        var body: some View {
            LineView(viewModel: viewModel)
        }

    }

    struct LineViewPreviewView: View {

        @StateObject var viewModel: LineViewModel

        var body: some View {
            LineView(viewModel: viewModel)
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
