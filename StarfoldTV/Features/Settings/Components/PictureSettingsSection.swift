//
//  PictureSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.picture.buffer.title", selection: $settings.pacingMode) {
                ForEach(settings.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Toggle("settings.picture.statistics", isOn: $settings.shouldShowStatistics)
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
        PictureSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
