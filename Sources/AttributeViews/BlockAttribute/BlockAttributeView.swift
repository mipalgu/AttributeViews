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

/// A view that display a block attribute.
/// 
/// This view is used to display any block attribute. Thus, the main content
/// of this view is delegated to many other different views depending on the
/// block attribute that is being displayed. Since a block attribute may be any
/// one of a number of attributes, this view simply provides a common interface
/// for displaying any of them.
public struct BlockAttributeView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: BlockAttributeViewModel

    /// Create a new `BlockAttributeView`.
    /// 
    /// - Parameter viewModel: The view model associated with this view.
    public init(viewModel: BlockAttributeViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    /// The content of this view.
    public var body: some View {
        viewModel.subView
    }

}
