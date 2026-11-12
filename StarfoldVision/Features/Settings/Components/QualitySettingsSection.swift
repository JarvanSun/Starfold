//
//  QualitySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct QualitySettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.quality.console", selection: $settings.consoleQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.consoleTitle).tag(choice)
                }
            }

            Picker("settings.quality.cloud", selection: $settings.cloudQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.cloudTitle).tag(choice)
                }
            }

            Picker("settings.bitrate.title", selection: $settings.maxBitrateMbps) {
                ForEach(settings.bitrateChoices, id: \.self) { bitrate in
                    Text(settings.title(ofBitrate: bitrate)).tag(bitrate)
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
        QualitySettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
