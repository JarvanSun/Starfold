//
//  MainToolbar.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct MainToolbar: ToolbarContent {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dimensions) private var dimensions

    let onShowSignIn: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            if app.sessionState == .signedIn {
                AccountMenu(onShowSignIn: onShowSignIn)
            }
        }

        ToolbarSpacer(.flexible)

        ToolbarItem(placement: .primaryAction) {
            ClockView()
                .padding(.horizontal, dimensions.spaceSmall)
        }
        .sharedBackgroundVisibility(.hidden)

        ToolbarItem(placement: .primaryAction) {
            settingsLink
        }
    }
}

private extension MainToolbar {
    var settingsLink: some View {
        SettingsLink {
            Label(String(localized: "toolbar.settings.label"), systemImage: "gearshape")
        }
        .help(Text("toolbar.settings.tooltip"))
    }
}
