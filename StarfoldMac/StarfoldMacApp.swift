//
//  StarfoldMacApp.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

@main
struct StarfoldMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dimensions) private var dimensions
    @State private var app = AppDependencies(streamPlatform: StreamPlatform()).makeAppViewModel()

    private var isHostingPreviewsOrTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        let isHostingPreviews = environment[HostEnvironmentKey.runningForPreviews.rawValue] == "1"
        let isHostingTests = environment[HostEnvironmentKey.testConfiguration.rawValue] != nil
        return isHostingPreviews || isHostingTests
    }

    var body: some Scene {
        Window(AppInfo().displayName, id: SceneID.main.rawValue) {
            mainWindow
        }
        .defaultSize(width: dimensions.mainWindowWidth, height: dimensions.mainWindowHeight)
        .commands { StreamCommands(app: app) }
        .onChange(of: scenePhase, initial: true) { app.setActive(scenePhase == .active) }

        Window(String(localized: "app.streamWindow.title"), id: SceneID.stream.rawValue) {
            streamWindow
        }
        .defaultSize(width: dimensions.streamWindowWidth, height: dimensions.streamWindowHeight)
        .windowResizability(.contentMinSize)
        .windowManagerRole(.principal)
        .restorationBehavior(.disabled)

        Settings {
            settingsWindow
        }

        MenuBarExtra(isInserted: isMenuBarIconInserted) {
            menuBarMenu
        } label: {
            menuBarIcon
        }
        .menuBarExtraStyle(.menu)
    }

    private var mainWindow: some View {
        MainWindowView()
            .opensStreamWindow()
            .paletteTint()
            .appPalette()
            .environment(app)
            .task { await launch() }
    }

    private func launch() async {
        appDelegate.app = app

        guard !isHostingPreviewsOrTests else { return }

        await app.restore()
    }

    private var streamWindow: some View {
        StreamWindowView()
            .paletteTint()
            .appPalette()
            .environment(app)
    }

    private var settingsWindow: some View {
        SettingsView(settings: app.settings)
            .paletteTint()
            .appPalette()
            .environment(app)
    }

    private var isMenuBarIconInserted: Binding<Bool> {
        switch isHostingPreviewsOrTests {
        case true: .constant(false)
        case false: Bindable(app.settings).shouldShowInMenuBar
        }
    }

    private var menuBarMenu: some View {
        MenuBarMenu()
            .environment(app)
    }

    private var menuBarIcon: some View {
        Image(systemName: "gamecontroller.fill")
            .accessibilityLabel(Text(verbatim: AppInfo().displayName))
            .opensStreamWindow()
            .environment(app)
    }
}

private enum HostEnvironmentKey: String {
    case runningForPreviews = "XCODE_RUNNING_FOR_PREVIEWS"
    case testConfiguration = "XCTestConfigurationFilePath"
}
