//
//  File.swift
//  File
//
//  Created by Morgan McColl on 5/9/21.
//

import Attributes
import AttributeViews
import Foundation
import GUUI

/// The view model for the test app.
final class AppViewModel<Root: Modifiable>: ObservableObject, GlobalChangeNotifier {

    /// A reference to the root `Modifiable` object.
    private let rootRef: Ref<Root>

    /// A path to the attribute groups within the base `Modifiable` object.
    let path: Attributes.Path<Root, [AttributeGroup]>

    /// The view models associated with each group.
    private var viewModels: [Int: AttributeGroupViewModel] = [:]

    /// The base `Modifiable` object.
    var root: Root {
        get {
            rootRef.value
        } set {
            rootRef.value = newValue
        }
    }

    /// The indices of the groups.
    var attributes: Range<Int> {
        rootRef.value[keyPath: path.keyPath].indices
    }

    /// Create a new `AppViewModel`.
    /// 
    /// - Parameter root: The base `Modifiable` object.
    /// 
    /// - Parameter path: An `Attribute.Path` to the attribute groups within the
    /// base `Modifiable` object.
    init(root: Ref<Root>, path: Attributes.Path<Root, [AttributeGroup]>) {
        self.rootRef = root
        self.path = path
    }

    /// Fetch the view model for a given group.
    /// 
    /// - Parameter index: The index of the group.
    /// 
    /// - Returns: The view model for the group.
    func viewModel(forIndex index: Int) -> AttributeGroupViewModel {
        if let viewModel = viewModels[index] {
            return viewModel
        }
        let viewModel = AttributeGroupViewModel(root: rootRef, path: path[index], notifier: self)
        viewModels[index] = viewModel
        return viewModel
    }

    /// Manually trigger an `objectWillChange` notification.
    /// 
    /// This function recursively triggers an `objectWillChange` notification
    /// to any child view models.
    func send() {
        objectWillChange.send()
        viewModels.values.forEach {
            $0.send()
        }
    }

}
