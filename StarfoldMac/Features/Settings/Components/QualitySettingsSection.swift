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
            consoleQualityPicker

            cloudQualityPicker

            bitratePicker
        } header: {
            Text("settings.streaming.quality.header")
        } footer: {
            Text("settings.streaming.quality.footer")
        }
    }

    private var consoleQualityPicker: some View {
        Picker(
            String(localized: "settings.streaming.consoleQuality.title"),
            selection: $settingsViewModel.consoleQuality
        ) {
            ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                Text(choice.consoleTitle).tag(choice)
            }
        }
    }

    private var cloudQualityPicker: some View {
        Picker(
            String(localized: "settings.streaming.cloudQuality.title"),
            selection: $settingsViewModel.cloudQuality
        ) {
            ForEach(settingsViewModel.qualityChoices, id: \.self) { choice in
                Text(choice.cloudTitle).tag(choice)
            }
        }
    }

    private var bitratePicker: some View {
        Picker(
            String(localized: "settings.streaming.bitrate.title"),
            selection: $settingsViewModel.maxBitrateMbps
        ) {
            ForEach(settingsViewModel.bitrateChoices, id: \.self) { bitrate in
                Text(settingsViewModel.title(ofBitrate: bitrate)).tag(bitrate)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        QualitySettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
