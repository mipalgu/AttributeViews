/*
 * Scene.swift
 * AttributeViewsTests
 *
 * Created by Callum McColl on 25/3/21.
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
import Foundation
import TokamakShim

/// Typealias State to `TokamakShim.State` to avoid conflicts.
typealias State = TokamakShim.State
#else
import SwiftUI

/// Typealias State to `SwiftUI.State` to avoid conflicts.
typealias State = SwiftUI.State
#endif

import Attributes
import AttributeViews
import GUUI

/// A scene for testing the functionality of AttributeViews.
struct TestsScene: App {

#if canImport(SwiftUI)

    /// The apps `NSApplicationDelegate`.
    class AppDelegate: NSObject, NSApplicationDelegate {

        /// Close the app if all windows have closed.
        func applicationShouldTerminateAfterLastWindowClosed(_ application: NSApplication) -> Bool {
            true
        }

        /// Set the activation policy to .regular.
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
        }

    }

    // swiftlint:disable weak_delegate

    /// The scenes app delegate.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

#endif

    // swiftlint:enable weak_delegate

    /// The scene phase.
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// Which views are visible.
    @State var expanded: [AnyKeyPath: Bool] = [:]

    /// The view model associated with this app.
    @StateObject var viewModel = AppViewModel(
        root: Ref(
            copying: EmptyModifiable(
                attributes: [
                    AttributeGroup(
                        name: "line_attributes",
                        fields: [
                            Field(name: "bool", type: .bool),
                            Field(name: "int", type: .integer),
                            Field(name: "float", type: .float),
                            Field(name: "line", type: .line),
                            Field(name: "expression", type: .expression(language: .swift)),
                            Field(name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))
                        ],
                        attributes: [
                            "bool": .bool(false),
                            "int": .integer(0),
                            "float": .float(0.0),
                            "line": .line(""),
                            "expression": .expression("", language: .swift),
                            "enumerated": .enumerated("a", validValues: ["a", "b", "c"])
                        ]
                    ),
                    AttributeGroup(
                        name: "block_attributes",
                        fields: [
                            Field(name: "text", type: .text),
                            Field(name: "code", type: .code(language: .swift)),
                            // Field(
                            //     name: "enumerated_collection",
                            //     type: .enumerableCollection(validValues: ["a", "b", "c"])
                            // ),
                            Field(
                                name: "table",
                                type: .table(
                                    columns: [
                                        (name: "bool", type: .bool),
                                        (name: "int", type: .integer),
                                        (name: "float", type: .float),
                                        (name: "line", type: .line),
                                        (name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))
                                    ]
                                )
                            )
                        ],
                        attributes: [
                            "text": .text(""),
                            "code": .code("", language: .swift),
                            // "enumerable_collection": .enumerableCollection(
                            //     ["a"],
                            //     validValues: ["a", "b", "c"]
                            // ),
                            "table": .table(
                                [
                                    [
                                        .bool(false),
                                        .integer(0),
                                        .float(0.0),
                                        .line(""),
                                        .enumerated("a", validValues: ["a", "b", "c"])
                                    ],
                                    [
                                        .bool(true),
                                        .integer(1),
                                        .float(0.1),
                                        .line("1"),
                                        .enumerated("b", validValues: ["a", "b", "c"])
                                    ]
                                ],
                                columns: [
                                    (name: "bool", type: .bool),
                                    (name: "int", type: .integer),
                                    (name: "float", type: .float),
                                    (name: "line", type: .line),
                                    (name: "enumerated", type: .enumerated(validValues: ["a", "b", "c"]))
                                ]
                            )
                        ]
                    ),
                    AttributeGroup(
                        name: "recursive_block_attributes",
                        fields: [
                            Field(name: "line_collection", type: .collection(type: .bool)),
                            Field(name: "code_collection", type: .collection(type: .code(language: .swift))),
                            Field(
                                name: "complex_collection",
                                type: .collection(
                                    type: .complex(
                                        layout: [
                                            Field(name: "bool", type: .bool),
                                            Field(name: "code", type: .code(language: .swift))
                                        ]
                                    )
                                )
                            ),
                            Field(
                                name: "complex",
                                type: .complex(
                                    layout: [
                                        Field(name: "bool", type: .bool),
                                        Field(name: "code", type: .code(language: .swift)),
                                        Field(
                                            name: "complex",
                                            type: .complex(
                                                layout: [
                                                    Field(name: "bool", type: .bool),
                                                    Field(name: "code", type: .code(language: .swift))
                                                ]
                                            )
                                        )
                                    ]
                                )
                            )
                        ],
                        attributes: [
                            "line_collection": .collection(bools: [false, true]),
                            "code_collection": .collection(
                                code: ["let a = 2", "let b = 3"],
                                language: .swift
                            ),
                            "complex_collection": .collection(
                                complex: [
                                    [
                                        "bool": .bool(false),
                                        "code": .code("let a = 2", language: .swift)
                                    ],
                                    [
                                        "bool": .bool(true),
                                        "code": .code("let b = 3", language: .swift)
                                    ]
                                ],
                                layout: [
                                    Field(name: "bool", type: .bool),
                                    Field(name: "code", type: .code(language: .swift))
                                ],
                                display: ReadOnlyPath<Attribute, Attribute>(keyPath: \.self, ancestors: [])
                                    .complexValue["code"]
                                    .wrappedValue
                                    .lineAttribute
                            ),
                            "complex": .complex(
                                [
                                    "bool": .bool(false),
                                    "code": .code("print(\"Hello\")", language: .swift),
                                    "complex": .complex(
                                        [
                                            "bool": .bool(true),
                                            "code": .code("print(\"World\")", language: .swift)
                                        ],
                                        layout: [
                                            Field(name: "bool", type: .bool),
                                            Field(name: "code", type: .code(language: .swift))
                                        ]
                                    )
                                ],
                                layout: [
                                    Field(name: "bool", type: .bool),
                                    Field(name: "code", type: .code(language: .swift)),
                                    Field(
                                        name: "complex",
                                        type: .complex(
                                            layout: [
                                                Field(name: "bool", type: .bool),
                                                Field(name: "code", type: .code(language: .swift))
                                            ]
                                        )
                                    )
                                ]
                            )
                        ]
                    )
                ],
                metaData: []
            )
        ),
        path: EmptyModifiable.path.attributes
    )

    /// Some editable text.
    @State var text: String = ""

    /// An error message.
    @State var loadError: String = ""

    /// The contents of this scene.
    var body: some Scene {
        WindowGroup {
            ScrollView(.vertical, showsIndicators: true) {
                if viewModel.attributes.isEmpty {
                    Text("No attributes to display.")
                } else {
                    ForEach(viewModel.attributes) { index in
                        AttributeGroupView(viewModel: viewModel.viewModel(forIndex: index))
                    }
                }
            }.padding(10)
        }
    }

}
