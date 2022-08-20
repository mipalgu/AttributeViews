/*
 * Editor.swift
 * 
 *
 * Created by Callum McColl on 26/4/21.
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

#if canImport(Cocoa)

import Cocoa
import Foundation

/// A source code editor.
struct Editor: NSViewControllerRepresentable {

    /// The coordinator that handles any delegate functionality from the editor.
    final class Coordinator: NSObject, NSTextViewDelegate {

        /// Are we currently editing?
        var editing = false

        // swiftlint:disable implicitly_unwrapped_optional

        /// The `NSTextView` that is being edited.
        var textView: NSTextView!

        // swiftlint:enable implicitly_unwrapped_optional

        /// A function that is called when wanting to change the value of the
        /// editor.
        let changeValue: (String) -> Void

        /// A function that is executed when editing has been completed.
        let onCommit: (String) -> Void

        /// Create a new `Coordinator`.
        /// 
        /// - Parameter changeValue: A function that is called when wanting to
        /// change the value of the editor.
        /// 
        /// - Parameter onCommit: A function that is executed when editing has
        /// been completed.
        init(changeValue: @escaping (String) -> Void, onCommit: @escaping (String) -> Void) {
            self.changeValue = changeValue
            self.onCommit = onCommit
        }

        /// Called when the view is disappearing from the screen.
        /// 
        /// Calls `onCommit` and sets `editing` to false.
        func viewWillDisappear() {
            if editing {
                onCommit(textView.string)
                editing = false
            }
        }

        /// Called when editing has been completed.
        /// 
        /// Calls `onCommit` and sets `editing` to false.
        ///
        /// - Parameter notification: The `Notification` that triggered this
        /// function to be called.
        func textDidEndEditing(_ notification: Notification) {
            onCommit(textView.string)
            editing = false
        }

        /// Triggered when the text within `textView` changes.
        ///
        /// Calls `onChangeValue` and sets `editing` to true.
        ///
        /// - Prameter notification: The notification that triggered this
        /// function to be called.
        func textDidChange(_ notification: Notification) {
            changeValue(textView.string)
            editing = true
        }

    }

    /// A binding to the text within the editor.
    @Binding var editingText: String

    /// The fillable size that the editor must fit in.
    let size: CGSize

    /// An optional function that is executed when editing has been completed.
    let onCommit: ((String) -> Void)?

    /// Create a new `Editor`.
    /// 
    /// - Parameter editingText: A binding to the text within the editor.
    /// 
    /// - Parameter size: The fillable size that the editor must fit in.
    /// 
    /// - Parameter onCommit: An optional function that is executed when editing
    /// has been completed.
    init(editingText: Binding<String>, size: CGSize, onCommit: ((String) -> Void)? = nil) {
        self._editingText = editingText
        self.size = size
        self.onCommit = onCommit
    }

    /// Create a new `Coordinator` for the editor.
    /// 
    /// - Returns: A new `Coordinator` for the editor.
    func makeCoordinator() -> Coordinator {
        Coordinator(
            changeValue: onCommit == nil ? { editingText = $0 } : { _ in },
            onCommit: onCommit ?? { _ in }
        )
    }

    /// Create the controller for the editor.
    /// 
    /// This function sets the delegate to the contexts coordinator so that
    /// the coordinator can be notified of changes happening within the editor.
    /// 
    /// - Parameter context: The context for the editor.
    /// 
    /// - Returns: The controller for the editor.
    func makeNSViewController(context: Context) -> EditorViewController {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.setFrameSize(size)
        guard let textView = scrollView.documentView as? NSTextView else {
            fatalError("Unable to convert `scrollView.documentView` to `NSTextView`")
        }
        if textView.isAutomaticTextReplacementEnabled {
            textView.toggleAutomaticTextReplacement(nil)
        }
        if textView.isAutomaticQuoteSubstitutionEnabled {
            textView.toggleAutomaticQuoteSubstitution(nil)
        }
        if textView.isAutomaticDataDetectionEnabled {
            textView.toggleAutomaticDataDetection(nil)
        }
        if textView.isAutomaticLinkDetectionEnabled {
            textView.toggleAutomaticLinkDetection(nil)
        }
        if textView.isAutomaticTextCompletionEnabled {
            textView.toggleAutomaticTextCompletion(nil)
        }
        if textView.isAutomaticDashSubstitutionEnabled {
            textView.toggleAutomaticDashSubstitution(nil)
        }
        if textView.isAutomaticSpellingCorrectionEnabled {
            textView.toggleAutomaticSpellingCorrection(nil)
        }
        textView.string = editingText
        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        let controller = EditorViewController(coordinator: context.coordinator)
        controller.view = scrollView
        return controller
    }

    /// Does nothing.
    func updateNSViewController(_: EditorViewController, context _: Context) {}

}

#else

import Attributes
import Foundation

// swiftlint:disable type_contents_order

/// A source code editor.
struct Editor: View {

    /// A binding to the source code being edited.
    @Binding var text: String

    /// The fillable size that the editor must fit in.
    var size: CGSize

    /// An optional function that is executed when editing has been completed.
    var onCommit: ((Code) -> Void)?

    /// Create a new `Editor`.
    /// 
    /// - Parameter editingText: A binding to the text within the editor.
    /// 
    /// - Parameter size: The fillable size that the editor must fit in.
    /// 
    /// - Parameter onCommit: An optional function that is executed when editing
    /// has been completed.
    init(editingText: Binding<String>, size: CGSize, onCommit: ((Code) -> Void)?) {
        self._text = editingText
        self.size = size
        self.onCommit = onCommit
    }

    /// The contents of this view.
    var body: some View {
        // swiftlint:disable:next trailing_closure
        TextField("", text: $text, onCommit: {
            guard let callback = self.onCommit else {
                return
            }
            callback(text)
        }).frame(width: size.width, height: size.height)
    }

}

#endif
