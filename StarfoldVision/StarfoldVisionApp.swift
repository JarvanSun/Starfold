//
//  StarfoldVisionApp.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

@main
struct StarfoldVisionApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dimensions) private var dimensions
    @State private var app = AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()

    var body: some Scene {
        WindowGroup(id: SceneID.main.rawValue) {
            RootView()
                .windowTint()
                .appPalette()
                .environment(app)
                .frame(
                    minWidth: dimensions.mainWindowMinimumWidth,
                    idealWidth: dimensions.mainWindowWidth,
                    maxWidth: dimensions.mainWindowMaximumWidth,
                    minHeight: dimensions.mainWindowMinimumHeight,
                    idealHeight: dimensions.mainWindowHeight,
                    maxHeight: dimensions.mainWindowMaximumHeight
                )
                .task { await app.restore() }
        }
        .defaultSize(width: dimensions.mainWindowWidth, height: dimensions.mainWindowHeight)
        .windowResizability(.contentSize)
        .onChange(of: scenePhase, initial: true) { app.setActive(scenePhase == .active) }

        WindowGroup(id: SceneID.stream.rawValue) {
            StreamWindowView()
                .windowTint()
                .appPalette()
                .environment(app)
        }
        .windowStyle(.plain)
        .defaultSize(width: dimensions.streamWindowWidth, height: dimensions.streamWindowHeight)
        .restorationBehavior(.disabled)
    }
}
