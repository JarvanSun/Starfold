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
            consoleQualityPicker

            cloudQualityPicker

            bitratePicker
        } header: {
            Text("settings.streaming.quality.header")
        } footer: {
            Text("settings.streaming.quality.footer")
        }
    }
}

private extension QualitySettingsSection {
    var consoleQualityPicker: some View {
        Picker(
            String(localized: "settings.streaming.consoleQuality.title"),
            selection: $settings.consoleQuality
        ) {
            ForEach(settings.qualityChoices, id: \.self) { choice in
                Text(choice.consoleTitle).tag(choice)
            }
        }
    }

    var cloudQualityPicker: some View {
        Picker(
            String(localized: "settings.streaming.cloudQuality.title"),
            selection: $settings.cloudQuality
        ) {
            ForEach(settings.qualityChoices, id: \.self) { choice in
                Text(choice.cloudTitle).tag(choice)
            }
        }
    }

    var bitratePicker: some View {
        Picker(
            String(localized: "settings.streaming.bitrate.title"),
            selection: $settings.maxBitrateMbps
        ) {
            ForEach(settings.bitrateChoices, id: \.self) { bitrate in
                Text(settings.title(ofBitrate: bitrate)).tag(bitrate)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        QualitySettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
