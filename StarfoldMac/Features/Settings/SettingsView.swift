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

    let settings: SettingsViewModel

    var body: some View {
        TabView {
            Tab(String(localized: "settings.tab.streaming"), systemImage: "play.tv") {
                StreamingSettings(settings: settings)
            }

            Tab(String(localized: "settings.tab.picture"), systemImage: "sparkles.tv") {
                PictureSettings(settings: settings)
            }

            Tab(String(localized: "settings.tab.controls"), systemImage: "gamecontroller") {
                ControlsSettings(settings: settings)
            }
        }
        .frame(width: dimensions.settingsWindowWidth)
    }
}

#if DEBUG
#Preview {
    SettingsView(settings: PreviewObjectPool.settingsViewModel)
}
#endif
