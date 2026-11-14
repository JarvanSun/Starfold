//
//  PacingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PacingSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            Picker(
                String(localized: "settings.picture.buffer.title"),
                selection: $settingsViewModel.pacingMode
            ) {
                ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
        } footer: {
            Text("settings.picture.buffer.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        PacingSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
