//
//  File.swift
//  File
//
//  Created by Morgan McColl on 5/9/21.
//

import Foundation

import TokamakShim
import AttributeViews
import Attributes
import GUUI


struct TriggerTests: App {
    
    class AppDelegate: NSObject, NSApplicationDelegate {
        
        func applicationShouldTerminateAfterLastWindowClosed(_ application: NSApplication) -> Bool {
            return true
        }
        
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
        }
        
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    @State var expanded: [AnyKeyPath: Bool] = [:]
    
    @StateObject var viewModel = AppViewModel(
        root: Ref(copying: EmptyModifiable(
            attributes: [
                AttributeGroup(
                    name: "hidden_view",
                    fields: [
                        Field(name: "show_view", type: .bool)
                    ],
                    attributes: [
                        "show_view": .bool(false)
                    ],
                    metaData: [:]
                )
            ],
            metaData: [],
            modifyTriggsy: {
                .success(false)
            }
        )),
        path: EmptyModifiable.path.attributes
    )
    
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
