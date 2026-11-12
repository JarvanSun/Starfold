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
    @Environment(AppViewModel.self) private var app
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        account

        switch (app.home, app.library) {
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
}

// MARK: - Private

private extension MenuBarMenu {
    var recentGameLimit: Int {
        3
    }

    @ViewBuilder
    var account: some View {
        switch (app.sessionState, app.signedInGamertag) {
        case (.signedIn, let gamertag?): Text(gamertag)
        case (.signedOut, _): Text("menuBar.signedOut.message")
        case (.signedIn, nil), (.restoring, _): EmptyView()
        }
    }

    @ViewBuilder
    var controllers: some View {
        if !app.settings.connectedControllers.isEmpty {
            Section(String(localized: "menuBar.controllers.title")) {
                ForEach(app.settings.connectedControllers, content: controllerLine(for:))
            }
        }
    }

    var openAppButton: some View {
        Button(String(localized: "menuBar.open \(AppInfo().displayName)"), action: openApp)
    }

    var settingsButton: some View {
        Button(String(localized: "menuBar.settings"), action: showSettings)
            .keyboardShortcut(",")
    }

    var quitButton: some View {
        Button(String(localized: "menuBar.quit \(AppInfo().displayName)")) {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    @ViewBuilder
    func consoles(of home: HomeViewModel) -> some View {
        if !home.consoles.isEmpty {
            Section(String(localized: "menuBar.consoles.title")) {
                ForEach(home.consoles) { console in
                    Button {
                        play(.console(id: console.id, name: console.name))
                    } label: {
                        Label(title(for: console, in: home), systemImage: "play.fill")
                    }
                }
            }
        }
    }

    @ViewBuilder
    func recentGames(of library: LibraryViewModel) -> some View {
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

    @ViewBuilder
    func controllerLine(for controller: ConnectedController) -> some View {
        switch app.settings.batteryLevel(of: controller) {
        case let battery?:
            Text("menuBar.controller.battery \(controller.name) \(percentText(battery))")
        case nil: Text(controller.name)
        }
    }

    func title(for console: Console, in home: HomeViewModel) -> String {
        switch home.activity(for: console) {
        case let activity? where activity.kind == .playingNow:
            String(localized: "menuBar.console.playing \(console.name) \(activity.name)")
        default: console.name
        }
    }

    func percentText(_ fraction: Double) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    func play(_ target: StreamTarget) {
        Task { await app.play(target) }
    }

    func openApp() {
        openWindow(id: SceneID.main.rawValue)

        NSApp.activate()
    }

    func showSettings() {
        NSApp.activate()

        openSettings()
    }
}
