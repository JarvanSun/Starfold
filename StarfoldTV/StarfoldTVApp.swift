//
//  StarfoldTVApp.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

@main
struct StarfoldTVApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var app = AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .untintedAppPalette()
                .environment(app)
                .task { await app.restore() }
        }
        .onChange(of: scenePhase, initial: true) { app.setActive(scenePhase == .active) }
    }
}
