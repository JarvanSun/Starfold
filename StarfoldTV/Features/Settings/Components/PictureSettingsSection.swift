//
//  PictureSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            ChoiceLink(
                "settings.picture.buffer.title",
                selection: $settingsViewModel.pacingMode,
                choices: settingsViewModel.pacingModes
            ) { Text($0.title) }

            Toggle("settings.picture.statistics", isOn: $settingsViewModel.shouldShowStatistics)
        } header: {
            Text("settings.picture.header")
        } footer: {
            Text("settings.picture.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        PictureSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
