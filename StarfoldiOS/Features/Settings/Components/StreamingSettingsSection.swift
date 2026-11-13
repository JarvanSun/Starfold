//
//  StreamingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct StreamingSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section("settings.streaming.header") {
            Picker("settings.quality.console.title", selection: $settings.consoleQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.consoleTitle).tag(choice)
                }
            }

            Picker("settings.quality.cloud.title", selection: $settings.cloudQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.cloudTitle).tag(choice)
                }
            }

            if settings.canUseCellular {
                cellularQualityPicker
            }

            Picker("settings.quality.bitrate.title", selection: $settings.maxBitrateMbps) {
                ForEach(settings.bitrateChoices, id: \.self) { bitrate in
                    Text(settings.title(ofBitrate: bitrate)).tag(bitrate)
                }
            }

            Picker("settings.picture.buffer.title", selection: $settings.pacingMode) {
                ForEach(settings.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Picker("settings.cloud.language.title", selection: $settings.gameLanguage) {
                ForEach(settings.gameLanguages, id: \.self) { code in
                    Text(verbatim: settings.name(ofGameLanguage: code)).tag(code)
                }
            }
        }
    }

    private var cellularQualityPicker: some View {
        Picker("settings.quality.cellular.title", selection: $settings.cellularQuality) {
            ForEach(settings.cellularQualityChoices, id: \.self) { choice in
                Text(choice.consoleTitle).tag(choice)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        StreamingSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
