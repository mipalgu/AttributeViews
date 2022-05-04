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

public struct LineAttributeView: View {

    @ObservedObject var viewModel: LineAttributeViewModel

    public init(viewModel: LineAttributeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        switch viewModel.lineAttribute.type {
        case .bool:
            BoolView(viewModel: viewModel.boolViewModel)
        case .integer:
            IntegerView(viewModel: viewModel.integerViewModel)
        case .float:
            FloatView(viewModel: viewModel.floatViewModel)
        case .expression:
            ExpressionView(viewModel: viewModel.expressionViewModel)
        case .enumerated(let validValues):
            EnumeratedView(viewModel: viewModel.enumeratedViewModel, validValues: validValues)
        case .line:
            LineView(viewModel: viewModel.lineViewModel)
        }
    }
}

