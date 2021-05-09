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

import Foundation
import Cocoa

final class EditorViewController: NSViewController {
    
    let coordinator: Editor.Coordinator
    
    init(coordinator: Editor.Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewWillDisappear() {
        coordinator.viewWillDisappear()
    }
    
}

struct Editor: NSViewControllerRepresentable {
    
    
    @Binding var editingText: String
    let size: CGSize
    
    let onCommit: ((String) -> Void)?
    
    init(editingText: Binding<String>, size: CGSize, onCommit: ((String) -> Void)? = nil) {
        self._editingText = editingText
        self.size = size
        self.onCommit = onCommit
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            changeValue: onCommit == nil ? { editingText = $0 } : { _ in },
            onCommit: onCommit ?? { _ in }
        )
    }
    
    func makeNSViewController(context: Context) -> EditorViewController {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.setFrameSize(size)
        let textView = scrollView.documentView as! NSTextView
        textView.string = editingText
        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        let controller = EditorViewController(coordinator: context.coordinator)
        controller.view = scrollView
        return controller
    }
    
    func updateNSViewController(_ nsViewController: EditorViewController, context: Context) {}
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        
        var editing: Bool = false
        
        var textView: NSTextView!
        
        let changeValue: (String) -> Void
        
        let onCommit: (String) -> Void
        
        init(changeValue: @escaping (String) -> Void, onCommit: @escaping (String) -> Void) {
            self.changeValue = changeValue
            self.onCommit = onCommit
        }
        
        func viewWillDisappear() {
            if editing {
                onCommit(textView.string)
                editing = false
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            onCommit(textView.string)
            editing = false
        }
        
        func textDidChange(_ notification: Notification) {
            changeValue(textView.string)
            editing = true
        }
        
    }
    
}

#endif
