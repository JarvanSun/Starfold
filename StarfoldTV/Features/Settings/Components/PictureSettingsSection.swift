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
            Picker("settings.picture.buffer.title", selection: $settingsViewModel.pacingMode) {
                ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }

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
