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
    @State private var appViewModel = AppDependencies(streamPlatform: StreamPlatform())
        .makeAppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .windowTint()
                .appPalette()
                .environment(appViewModel)
                .task { await appViewModel.restore() }
        }
        .onChange(of: scenePhase, initial: true) { appViewModel.setActive(scenePhase == .active) }
    }
}
