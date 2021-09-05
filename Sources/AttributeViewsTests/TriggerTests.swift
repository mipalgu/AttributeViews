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
                        Field(name: "show_view", type: .bool),
                        Field(name: "data", type: .line)
                    ],
                    attributes: [
                        "show_view": .bool(true),
                        "data": .line("Hidden Data")
                    ],
                    metaData: [:]
                )
            ],
            metaData: [],
            modifyTriggsy: {
                guard let showView = $0.attributes[0].attributes["show_view"]?.boolValue else {
                    fatalError("No show view")
                }
                if showView {
                    guard $0.attributes[0].fields.count == 1 else {
                        return .success(false)
                    }
                    $0.attributes[0].fields.append(
                        Field(name: "data", type: .line)
                    )
                    return .success(true)
                }
                guard $0.attributes[0].fields.count == 2 else {
                    return .success(false)
                }
                $0.attributes[0].fields.removeLast()
                return .success(true)
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
