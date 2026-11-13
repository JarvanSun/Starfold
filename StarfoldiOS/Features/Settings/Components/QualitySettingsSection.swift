//
//  QualitySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct QualitySettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
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
        } header: {
            Text("settings.quality.header")
        } footer: {
            Text("settings.quality.footer")
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
        QualitySettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
