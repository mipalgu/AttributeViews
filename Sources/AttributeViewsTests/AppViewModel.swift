//
//  File.swift
//  File
//
//  Created by Morgan McColl on 5/9/21.
//

import Foundation
import AttributeViews
import Attributes
import GUUI

final class AppViewModel<Root: Modifiable>: ObservableObject, GlobalChangeNotifier {
    
    private let rootRef: Ref<Root>
    
    public let path: Attributes.Path<Root, [AttributeGroup]>
    
    private var viewModels: [Int: AttributeGroupViewModel] = [:]
    
    var root: Root {
        get {
            rootRef.value
        } set {
            rootRef.value = newValue
        }
    }
    
    var attributes: Range<Int> {
        rootRef.value[keyPath: path.keyPath].indices
    }
    
    init(root: Ref<Root>, path: Attributes.Path<Root, [AttributeGroup]>) {
        self.rootRef = root
        self.path = path
    }
    
    func viewModel(forIndex index: Int) -> AttributeGroupViewModel {
        if let viewModel = viewModels[index] {
            return viewModel
        }
        let viewModel = AttributeGroupViewModel(root: rootRef, path: path[index], notifier: self)
        viewModels[index] = viewModel
        return viewModel
    }
    
    func send() {
        objectWillChange.send()
        viewModels.values.forEach {
            $0.send()
        }
    }
    
}
