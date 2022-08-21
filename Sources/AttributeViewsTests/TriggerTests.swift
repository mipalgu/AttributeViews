//
//  File.swift
//  File
//
//  Created by Morgan McColl on 5/9/21.
//

import Foundation

import Attributes
import AttributeViews
import GUUI
import TokamakShim

/// A test app for testing triggers.
struct TriggerTests: App {

    /// The `NSApplicationDelegate`.
    class AppDelegate: NSObject, NSApplicationDelegate {

        /// Close the app if all windows are closed.
        func applicationShouldTerminateAfterLastWindowClosed(_ application: NSApplication) -> Bool {
            true
        }

        /// Set the activation policy to regular.
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
        }

    }

    // swiftlint:disable weak_delegate

    /// The app delegate.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // swiftlint:enable weak_delegate

    /// The scene phase.
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// Which views are expanded
    @State var expanded: [AnyKeyPath: Bool] = [:]

    // swiftlint:disable closure_body_length

    /// The view model associated with this app.
    @StateObject var viewModel = AppViewModel(
        root: Ref(copying: EmptyModifiable(
            attributes: [
                AttributeGroup(
                    name: "hidden_view",
                    fields: [
                        Field(name: "show_view", type: .bool),
                        Field(name: "data", type: .line)
                    ],
                    attributes: [
                        "show_view": .bool(true),
                        "data": .line("Hidden Data")
                    ],
                    metaData: [:]
                ),
                AttributeGroup(
                    name: "complex_hidden_view",
                    fields: [
                        Field(name: "hidden_context", type: .complex(layout: [
                            Field(name: "show_view", type: .bool),
                            Field(name: "code", type: .code(language: .swift))
                        ]))
                    ],
                    attributes: [
                        "hidden_context": .complex([
                            "show_view": .bool(true),
                            "code": .code("", language: .swift)
                        ], layout: [
                            Field(name: "show_view", type: .bool),
                            Field(name: "code", type: .code(language: .swift))
                        ])
                    ],
                    metaData: [:]
                )
            ],
            metaData: []
        ) {
            guard let showView = $0.attributes[0].attributes["show_view"]?.boolValue else {
                fatalError("No show view")
            }
            var redraw = false
            if showView {
                if $0.attributes[0].fields.count == 1 {
                    $0.attributes[0].fields.append(
                        Field(name: "data", type: .line)
                    )
                    redraw = true
                }
            } else {
                if $0.attributes[0].fields.count == 2 {
                    $0.attributes[0].fields.removeLast()
                    redraw = true
                }
            }
            guard
                let complexFields = $0.attributes[1].attributes["hidden_context"]?.complexFields,
                let showComplex = $0
                    .attributes[1]
                    .attributes["hidden_context"]?
                    .complexValue["show_view"]?
                    .boolValue
            else {
                fatalError("no show view of complex hidden view")
            }
            if showComplex {
                if complexFields.count == 1 {
                    $0.attributes[1].attributes["hidden_context"]?.complexFields.append(
                        Field(name: "code", type: .code(language: .swift))
                    )
                    redraw = true
                }
            } else {
                if complexFields.count == 2 {
                    $0.attributes[1].attributes["hidden_context"]?.complexFields.removeLast()
                    redraw = true
                }
            }
            return .success(redraw)
        }),
        path: EmptyModifiable.path.attributes
    )

    // swiftlint:enable closure_body_length

    /// The contents of this app.
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
