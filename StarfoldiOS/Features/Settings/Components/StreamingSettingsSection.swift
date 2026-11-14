//
//  StreamingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct StreamingSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section("settings.streaming.header") {
            Picker("settings.quality.console.title", selection: $settingsViewModel.consoleQuality) {
                ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                    Text(choice.consoleTitle).tag(choice)
                }
            }

            Picker("settings.quality.cloud.title", selection: $settingsViewModel.cloudQuality) {
                ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                    Text(choice.cloudTitle).tag(choice)
                }
            }

            if settingsViewModel.canUseCellular {
                cellularQualityPicker
            }

            Picker("settings.quality.bitrate.title", selection: $settingsViewModel.maxBitrateMbps) {
                ForEach(settingsViewModel.bitrateChoices, id: \.self) { bitrate in
                    Text(settingsViewModel.title(ofBitrate: bitrate)).tag(bitrate)
                }
            }

            Picker("settings.picture.buffer.title", selection: $settingsViewModel.pacingMode) {
                ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Picker("settings.cloud.language.title", selection: $settingsViewModel.gameLanguage) {
                ForEach(settingsViewModel.gameLanguages, id: \.self) { code in
                    Text(verbatim: settingsViewModel.name(ofGameLanguage: code)).tag(code)
                }
            }
        }
    }

    private var cellularQualityPicker: some View {
        Picker("settings.quality.cellular.title", selection: $settingsViewModel.cellularQuality) {
            ForEach(settingsViewModel.cellularQualityChoices, id: \.self) { choice in
                Text(choice.consoleTitle).tag(choice)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        StreamingSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
