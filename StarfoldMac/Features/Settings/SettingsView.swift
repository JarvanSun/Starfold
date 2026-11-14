//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    @Environment(\.dimensions) private var dimensions

    let settingsViewModel: SettingsViewModel

    var body: some View {
        TabView {
            Tab(String(localized: "settings.tab.streaming"), systemImage: "play.tv") {
                StreamingSettings(settingsViewModel: settingsViewModel)
            }

            Tab(String(localized: "settings.tab.picture"), systemImage: "sparkles.tv") {
                PictureSettings(settingsViewModel: settingsViewModel)
            }

            Tab(String(localized: "settings.tab.controls"), systemImage: "gamecontroller") {
                ControlsSettings(settingsViewModel: settingsViewModel)
            }
        }
        .frame(width: dimensions.settingsWindowWidth)
    }
}

#if DEBUG
#Preview {
    SettingsView(settingsViewModel: PreviewObjectPool.settingsViewModel)
}
#endif
