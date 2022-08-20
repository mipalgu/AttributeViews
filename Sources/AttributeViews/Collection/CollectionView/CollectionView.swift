/*
 * CollectionView.swift
 * MachineViews
 *
 * Created by Callum McColl on 16/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import GUUI

/// A view that displays a collection of attributes.
/// 
/// The collection contains a header and a body. The header contains the
/// title of the collection with the errors vertically stacked below the title.
/// The body contains vertically stacked rows with contents of the collection.
/// 
/// The behaviour of creating a new attribute depends on the type of attribute
/// that is being created. In this case, if the attribute type is a
/// `LineAttributeType`, then the creation of the new attribute is provided
/// utilising a field at the top of the collection. Conversely, if the attribute
/// type is a `BlockAttributeType`, then the creation of the new attribute is
/// handled utilising a sheet.
public struct CollectionView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: CollectionViewModel

    /// The content of the view.
    public var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.label.pretty.capitalized)
                .font(.headline)
            ForEach(viewModel.listErrors, id: \.self) { error in
                Text(error).foregroundColor(.red)
            }
            ZStack(alignment: .bottom) {
                CollectionBodyView(viewModel: viewModel.collectionBodyViewModel)
                NewAttributeView(viewModel: viewModel.newRowViewModel)
            }
        }
    }

}

#if canImport(SwiftUI)

/// The previews of associated with `CollectionView`.
struct CollectionView_Previews: PreviewProvider {

    /// A view that renders a `CollectionView` preview containing
    /// text attributes that exist within a `Modifiable` object.
    struct BlockRoot_Preview: View {

        /// The `Modifiable` object containing the text attributes.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "text",
                        type: .collection(type: .text)
                    )
                ],
                attributes: [
                    "text": .collection(text: ["Hello", "World"])
                ],
                metaData: [:]
            )
        ])

        /// The path to the collection within the `Modifiable` object.
        let path = EmptyModifiable.path.attributes[0].attributes["text"].wrappedValue.collectionValue

        /// The `CollectionView`.
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Block Root",
                    type: .line
                )
            )
        }

    }

    /// A view that renders a `CollectionView` preview containing
    /// text attributes that do not exist within a `Modifiable` object.
    struct BlockBinding_Preview: View {

        /// An array of text attributes that the `CollectionView` will manage.
        @State var value: [Attribute] = []

        /// The `CollectionView` initialised with a reference to `value`.
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef(copying: []),
                    label: "Block Binding",
                    type: .text,
                    delayEdits: false
                )
            )
        }

    }

    /// A view that renders a `CollectionView` preview containing
    /// line attributes that exist within a `Modifiable` object.
    struct LineRoot_Preview: View {

        /// The `Modifiable` object containing the line attributes.
        @State var modifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields",
                fields: [
                    Field(
                        name: "lines",
                        type: .collection(type: .line)
                    )
                ],
                attributes: [
                    "lines": .collection(lines: ["Hello", "World"])
                ],
                metaData: [:]
            )
        ])

        /// The path to the collection within the `Modifiable` object.
        let path = EmptyModifiable.path.attributes[0].attributes["lines"].wrappedValue.collectionValue

        /// The `CollectionView`.
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    root: Ref(get: { self.modifiable }, set: { self.modifiable = $0 }),
                    path: path,
                    label: "Line Root",
                    type: .line
                )
            )
        }

    }

    /// A view that renders a `CollectionView` preview containing
    /// line attributes that do not exist within a `Modifiable` object.
    struct LineBinding_Preview: View {

        /// An array of line attributes that the `CollectionView` will manage.
        @State var value: [Attribute] = []

        /// The `CollectionView` initialised with a reference to `value`.
        var body: some View {
            CollectionViewPreviewView(
                viewModel: CollectionViewModel(
                    valueRef: Ref(get: { self.value }, set: { self.value = $0 }),
                    errorsRef: ConstRef(copying: []),
                    label: "Line Binding",
                    type: .bool,
                    delayEdits: false
                )
            )
        }

    }

    /// A view that creates a @StateObject `CollectionViewModel` and passes
    /// it to the `CollectionView`.
    struct CollectionViewPreviewView: View {

        /// The view model associated with the `CollectionView`.
        @StateObject var viewModel: CollectionViewModel

        /// Create a new `CollectionView`, passing it the `viewModel`.
        var body: some View {
            CollectionView(viewModel: viewModel)
        }

    }

    /// The previews associated with `CollectionView` vertically stacked in
    /// this order:
    ///     - `LineRoot_Preview`
    ///     - `LineBinding_Preview`
    ///     - `BlockRoot_Preview`
    ///     - `BlockBinding_Preview`
    static var previews: some View {
        VStack {
            LineRoot_Preview()
            LineBinding_Preview()
            BlockRoot_Preview()
            BlockBinding_Preview()
        }
    }
}

#endif
