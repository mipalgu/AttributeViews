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

public struct BlockAttributeView: View{

    @ObservedObject var viewModel: BlockAttributeViewModel
    
    public init(viewModel: BlockAttributeViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        viewModel.subView
    }
}
