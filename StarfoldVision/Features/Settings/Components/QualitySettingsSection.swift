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
            Picker("settings.quality.console", selection: $settingsViewModel.consoleQuality) {
                ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                    Text(choice.consoleTitle).tag(choice)
                }
            }

            Picker("settings.quality.cloud", selection: $settingsViewModel.cloudQuality) {
                ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                    Text(choice.cloudTitle).tag(choice)
                }
            }

            Picker("settings.bitrate.title", selection: $settingsViewModel.maxBitrateMbps) {
                ForEach(settingsViewModel.bitrateChoices, id: \.self) { bitrate in
                    Text(settingsViewModel.title(ofBitrate: bitrate)).tag(bitrate)
                }
            }
        } header: {
            Text("settings.quality.title")
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
