//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    let settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            QualitySettingsSection(settingsViewModel: settingsViewModel)

            CloudGamingSettingsSection(settingsViewModel: settingsViewModel)

            PictureSettingsSection(settingsViewModel: settingsViewModel)

            SoundSettingsSection(settingsViewModel: settingsViewModel)

            ControllerSettingsSection(settingsViewModel: settingsViewModel)
        }
        .navigationTitle("settings.title")
    }
}

#if DEBUG
#Preview("Settings") {
    NavigationStack {
        SettingsView(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
