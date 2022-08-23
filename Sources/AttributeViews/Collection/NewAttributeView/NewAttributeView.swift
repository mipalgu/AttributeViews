/*
 * NewAttributeView.swift
 * 
 *
 * Created by Callum McColl on 4/5/2022.
 * Copyright © 2022 Callum McColl. All rights reserved.
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

/// The view for adding a new attribute to a collection.
/// 
/// This view is utilised by the `CollectionView` in order to handle the
/// creation of new attributes that are added to a collection attribute.
/// The behaviour of this view changes depending on the type of the attribute
/// within the collection. If the type of the attribute within the collection is
/// a `LineAttributeType`, then the view will display an `AttributeView` that 
/// allows the user to edit the new attribute. However, if the type of the
/// attribute within the collection is a `BlockAttributeType`, then the view
/// displays an "AddItem" button that when pressed will display a sheet that
/// contains a `ChangeItemView` for creating the new attribute.
/// 
/// - SeeAlso: `CollectionView`.
/// - SeeAlso: `AttributeView`.
/// - SeeAlso: `ChangeItemView`.
struct NewAttributeView: View {

    /// The view model associated with this view.
    @ObservedObject var viewModel: NewAttributeViewModel

    // @EnvironmentObject var config: Config

    /// The content of this view.
    var body: some View {
        VStack {
            HStack {
                if viewModel.newRow.attribute.isLine {
                    AttributeView(viewModel: viewModel.newRow)
                } else {
                    Text("Add Item")
                }
                VStack {
                    if viewModel.newRow.attribute.isLine {
                        Button {
                            self.viewModel.addElement()
                        } label: {
                            Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    } else {
                        Button {
                            self.viewModel.showSheet.toggle()
                        } label: {
                            Image(systemName: "plus").font(.system(size: 16, weight: .regular))
                        }.buttonStyle(PlainButtonStyle()).foregroundColor(.blue)
                    }
                }.frame(width: 20)
            }
        }.padding(.leading, 15)
            .padding(.trailing, 18)
            .padding(.bottom, 15)
            .sheet(isPresented: $viewModel.showSheet) {
                ChangeItemView(
                    label: "Add Item",
                    onSave: viewModel.addElement
                ) {
                    viewModel.showSheet = false
                } subView: {
                    AttributeView(viewModel: viewModel.newRow)
                }
            }
    }

}
