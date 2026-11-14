//
//  MenuBarMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/30.
//

import AppKit
import StarfoldShared
import StreamKit
import SwiftUI
import XboxKit

struct MenuBarMenu: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        account

        switch (appViewModel.homeViewModel, appViewModel.libraryViewModel) {
        case (let home?, let library?):
            consoles(of: home)

            recentGames(of: library)
        default: EmptyView()
        }

        controllers

        Divider()

        openAppButton

        settingsButton

        quitButton
    }

    @ViewBuilder
    private var account: some View {
        switch (appViewModel.sessionState, appViewModel.signedInGamertag) {
        case (.signedIn, let gamertag?): Text(gamertag)
        case (.signedOut, _): Text("menuBar.signedOut.message")
        case (.signedIn, nil), (.restoring, _): EmptyView()
        }
    }

    @ViewBuilder
    private func consoles(of home: HomeViewModel) -> some View {
        if !home.consoles.isEmpty {
            Section(String(localized: "menuBar.consoles.title")) {
                ForEach(home.consoles) { console in
                    let playingTitle = console.playingTitle(activity: home.activity(for: console))

                    Button {
                        play(.console(id: console.id, name: console.name))
                    } label: {
                        Label(
                            playingTitle.map { String(localized: $0) } ?? console.name,
                            systemImage: "play.fill"
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func recentGames(of library: LibraryViewModel) -> some View {
        let recentGameLimit = 3
        let recentGames = library.recentGames.prefix(recentGameLimit)
        if !recentGames.isEmpty {
            Section(String(localized: "menuBar.recentGames.title")) {
                ForEach(recentGames) { game in
                    Button {
                        play(.cloud(titleID: game.id, name: game.name))
                    } label: {
                        Label(game.name, systemImage: "cloud")
                    }
                }
            }
        }
    }

    private func play(_ target: StreamTarget) {
        Task { await appViewModel.play(target) }
    }

    @ViewBuilder
    private var controllers: some View {
        if !appViewModel.settingsViewModel.connectedControllers.isEmpty {
            Section(String(localized: "menuBar.controllers.title")) {
                ForEach(appViewModel.settingsViewModel.connectedControllers) {
                    controllerLine(for: $0)
                }
            }
        }
    }

    @ViewBuilder
    private func controllerLine(for controller: ConnectedController) -> some View {
        switch appViewModel.settingsViewModel.batteryLevel(of: controller) {
        case let battery?:
            Text("menuBar.controller.battery \(controller.name) \(percentText(battery))")
        case nil: Text(controller.name)
        }
    }

    private func percentText(_ fraction: Double) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    private var openAppButton: some View {
        Button(String(localized: "menuBar.open \(AppInfo().displayName)")) { openApp() }
    }

    private func openApp() {
        openWindow(id: SceneID.main.rawValue)

        NSApp.activate()
    }

    private var settingsButton: some View {
        Button(String(localized: "menuBar.settings")) { showSettings() }
            .keyboardShortcut(",")
    }

    private func showSettings() {
        NSApp.activate()

        openSettings()
    }

    private var quitButton: some View {
        Button(String(localized: "menuBar.quit \(AppInfo().displayName)")) {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
