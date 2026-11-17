//
//  QualitySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct QualitySettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            ChoiceLink(
                "settings.quality.console.title",
                selection: $settingsViewModel.consoleQuality,
                choices: settingsViewModel.qualityChoices
            ) { Text($0.consoleTitle) }

            ChoiceLink(
                "settings.quality.cloud.title",
                selection: $settingsViewModel.cloudQuality,
                choices: settingsViewModel.qualityChoices
            ) { Text($0.cloudTitle) }
        } header: {
            Text("settings.quality.header")
        } footer: {
            Text("settings.quality.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        QualitySettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
