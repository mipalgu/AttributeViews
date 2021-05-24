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
        viewModel.subView
    }
}

