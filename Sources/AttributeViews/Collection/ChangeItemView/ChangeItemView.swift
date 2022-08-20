//
/*
 * File.swift
 * 
 *
 * Created by Callum McColl on 18/9/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

// swiftlint:disable type_contents_order

/// A view that displays within a sheet for modifying an object.
public struct ChangeItemView<SubView: View>: View {

    /// The label to display for the view.
    let label: String

    /// A function that is invoked when saving the object.
    let onSave: (() -> Void)?

    /// A function that is invoked when deleting the object.
    let onDelete: (() -> Void)?

    /// A function that is invoked when dismissing the sheet.
    let onDismiss: (() -> Void)?

    /// A function that returns the sub view to display.
    let subView: () -> SubView

    /// Create a new `ChangeItemView`.
    /// 
    /// - Parameter label: The label to display for the view.
    /// 
    /// - Parameter onSave: A function that is invoked when saving the object.
    /// 
    /// - Parameter onDelete: A function that is invoked when deleting the
    /// object.
    /// 
    /// - Parameter subView: A function that returns the sub view to display.
    public init(
        label: String,
        onSave: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        subView: @escaping () -> SubView
    ) {
        self.init(label: label, onSave: onSave, onDelete: onDelete, onDismiss: nil, subView: subView)
    }

    /// Create a new `ChangeItemView`.
    /// 
    /// - Parameter label: The label to display for the view.
    /// 
    /// - Parameter onDismiss: A function that is invoked when dismissing the
    /// view.
    /// 
    /// - Parameter subView: A function that returns the sub view to display.
    public init(label: String, onDismiss: (() -> Void)?, subView: @escaping () -> SubView) {
        self.init(label: label, onSave: nil, onDelete: nil, onDismiss: onDismiss, subView: subView)
    }

    /// Create a new `ChangeItemView`.
    /// 
    /// - Parameter label: The label to display for the view.
    /// 
    /// - Parameter onSave: A function that is invoked when saving the object.
    /// 
    /// - Parameter onDelete: A function that is invoked when deleting the
    /// object.
    /// 
    /// - Parameter onDismiss: A function that is invoked when dismissing the
    /// view.
    /// 
    /// - Parameter subView: A function that returns the sub view to display.
    private init(
        label: String,
        onSave: (() -> Void)?,
        onDelete: (() -> Void)?,
        onDismiss: (() -> Void)?,
        subView: @escaping () -> SubView
    ) {
        self.label = label
        self.onSave = onSave
        self.onDelete = onDelete
        self.onDismiss = onDismiss
        self.subView = subView
    }

    /// The content of the view.
    public var body: some View {
        // swiftlint:disable:next closure_body_length
        VStack {
            ZStack(alignment: .top) {
                Text(label).font(.headline)
                HStack {
                    if let onDismiss = onDismiss {
                        Button(action: onDismiss) {
                            Image(systemName: "arrowshape.turn.up.backward")
                                .font(.system(size: 16, weight: .regular))
                        }.buttonStyle(.plain)
                    }
                    Spacer()
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.red)
                        }.buttonStyle(.plain)
                    }
                    if let onSave = onSave {
                        Button(action: onSave) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.blue)
                        }.buttonStyle(.plain)
                    }
                }
            }
            subView()
        }.frame(minWidth: 200, minHeight: 200).padding(10)
    }

}

#if canImport(SwiftUI)

/// The previews associated with `ChangeItemView`.
struct ChangeItemView_Previews: PreviewProvider {

    /// A view that renders the `ChangeItemView`, passing no functions
    /// for any actions.
    struct Preview: View {

        /// The contents of the preview.
        var body: some View {
            ChangeItemView(label: "Add Item") {
                Text("Some Text Here")
            }
        }

    }

    /// A previes associated with the `ChangeItemView`.
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
#endif
