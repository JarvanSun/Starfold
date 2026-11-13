//
//  StarfoldiOSApp.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

@main
struct StarfoldiOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var app = AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .appPalette()
                .environment(app)
                .environment(appDelegate.orientation)
                .task { await app.restore() }
        }
        .onChange(of: scenePhase, initial: true) { app.setActive(scenePhase == .active) }
    }
}
