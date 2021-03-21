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

public struct BlockAttributeView<Config: AttributeViewConfig, Root: Modifiable>: View{

    let subView: () -> AnyView
    
    public init(root: Binding<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String) {
        self.subView = {
            switch root.wrappedValue[keyPath: path.keyPath].type {
            case .code(let language):
                return AnyView(CodeView<Config, Text>(root: root, path: path.codeValue, label: label, language: language))
            case .text:
                return AnyView(TextView<Config>(root: root, path: path.textValue, label: label))
            case .collection(let type):
                return AnyView(CollectionView<Config, Root>(root: root, path: path.collectionValue, label: label, type: type))
            case .table(let columns):
                return AnyView(TableView<Config, Root>(root: root, path: path.tableValue, label: label, columns: columns))
            case .complex(let fields):
                return AnyView(ComplexView<Config, Root>(root: root, path: path.complexValue, label: label, fields: fields))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView<Config>(root: root, path: path.enumerableCollectionValue, label: label, validValues: validValues))
            }
        }
    }
    
    init(root: Binding<Root>, attribute: Binding<BlockAttribute>, label: String) {
        self.subView = {
            switch attribute.wrappedValue.type {
            case .code(let language):
                return AnyView(CodeView<Config, Text>(value: attribute.codeValue, label: label, language: language))
            case .text:
                return AnyView(TextView<Config>(value: attribute.textValue, label: label))
            case .collection(let type):
                return AnyView(CollectionView<Config, Root>(root: root, value: attribute.collectionValue, label: label, type: type))
            case .table(let columns):
                return AnyView(TableView<Config, Root>(root: root, value: attribute.tableValue, label: label, columns: columns))
            case .complex(let fields):
                return AnyView(ComplexView<Config, Root>(root: root, value: attribute.complexValue, label: label, fields: fields))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView<Config>(value: attribute.enumerableCollectionValue, label: label, validValues: validValues))
            }
        }
    }
    
    public var body: some View {
        subView()
    }
}
