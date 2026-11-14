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
    @State private var appViewModel = AppDependencies(streamPlatform: StreamPlatform())
        .makeAppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .windowTint()
                .appPalette()
                .environment(appViewModel)
                .environment(appDelegate.orientationLock)
                .task { await appViewModel.restore() }
        }
        .onChange(of: scenePhase, initial: true) { appViewModel.setActive(scenePhase == .active) }
    }
}
