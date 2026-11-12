//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    let settings: SettingsViewModel

    var body: some View {
        Form {
            QualitySettingsSection(settings: settings)

            CloudGamingSettingsSection(settings: settings)

            PictureSettingsSection(settings: settings)

            SoundSettingsSection(settings: settings)

            ControllerSettingsSection(settings: settings)
        }
        .navigationTitle("settings.title")
    }
}

#if DEBUG
#Preview("Settings") {
    NavigationStack {
        SettingsView(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
