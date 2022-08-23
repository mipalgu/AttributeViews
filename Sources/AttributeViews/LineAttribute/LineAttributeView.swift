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

/// A view that displays and allows editing of a `LineAttribute`.
/// 
/// Since a `LineAttribute` is an enum, and can thus be one of many cases,
/// this view handles this display and editing of each case. This makes it
/// possible to create this view using any of the `LineAttribute` cases and
/// receive a single view that displays the case correctly.
public struct LineAttributeView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: LineAttributeViewModel

    /// Create a new `LineAttributeView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: LineAttributeViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The contents of this view.
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
