//
//  PacingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PacingSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker(
                String(localized: "settings.picture.buffer.title"),
                selection: $settings.pacingMode
            ) {
                ForEach(settings.pacingModes, id: \.self) { mode in
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
        PacingSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
