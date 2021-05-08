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

public struct BlockAttributeView<Config: AttributeViewConfig>: View{

    let subView: () -> AnyView
    
    public init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String, expanded: Binding<[AnyKeyPath: Bool]>? = nil, notifier: GlobalChangeNotifier? = nil) {
        self.subView = {
            switch root.wrappedValue[keyPath: path.keyPath].type {
            case .code(let language):
                return AnyView(CodeView<Config, Text>(root: root, path: path.codeValue, label: label, language: language, notifier: notifier))
            case .text:
                return AnyView(TextView<Config>(root: root, path: path.textValue, label: label, notifier: notifier))
            case .collection(let type):
                return AnyView(CollectionView<Config>(root: root, path: path.collectionValue, display: root.wrappedValue[keyPath: path.keyPath].collectionDisplay, label: label, type: type, expanded: expanded, notifier: notifier))
            case .table(let columns):
                return AnyView(TableView<Config>(root: root, path: path.tableValue, label: label, columns: columns, notifier: notifier))
            case .complex(let fields):
                return AnyView(ComplexView<Config>(root: root, path: path.complexValue, label: label, fields: fields, expanded: expanded, notifier: notifier))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView<Config>(root: root, path: path.enumerableCollectionValue, label: label, validValues: validValues, notifier: notifier))
            }
        }
    }
    
    public init(attribute: Binding<BlockAttribute>, errors: Binding<[String]> = .constant([]), subErrors: @escaping (ReadOnlyPath<BlockAttribute, Attribute>) -> [String], label: String, delayEdits: Bool = false) {
        self.subView = {
            switch attribute.wrappedValue.type {
            case .code(let language):
                return AnyView(CodeView<Config, Text>(value: attribute.codeValue, label: label, language: language, delayEdits: delayEdits))
            case .text:
                return AnyView(TextView<Config>(value: attribute.textValue, label: label, delayEdits: delayEdits))
            case .collection(let type):
                return AnyView(CollectionView<Config>(value: attribute.collectionValue, display: attribute.wrappedValue.collectionDisplay, label: label, type: type, delayEdits: delayEdits))
            case .table(let columns):
                return AnyView(TableView<Config>(value: attribute.tableValue, label: label, columns: columns, delayEdits: delayEdits))
            case .complex(let fields):
                return AnyView(
                    ComplexView<Config>(
                        value: attribute.complexValue,
                        errors: errors,
                        subErrors: {
                            let keyPath: KeyPath<BlockAttribute, [String: Attribute]> = \.complexValue
                            let path = ReadOnlyPath<BlockAttribute, Attribute>(keyPath: keyPath.appending(path: $0.keyPath), ancestors: [])
                            return subErrors(path)
                        },
                        label: label,
                        fields: fields,
                        delayEdits: delayEdits
                    )
                )
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView<Config>(value: attribute.enumerableCollectionValue, label: label, validValues: validValues))
            }
        }
    }
    
    public var body: some View {
        subView()
    }
}
