//
//  ControlsSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ControlsSettings: View {
    @Environment(\.dimensions) private var dimensions

    let settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            ControllerSettingsSection(settingsViewModel: settingsViewModel)

            KeyboardSettingsSection(settingsViewModel: settingsViewModel)
        }
        .formStyle(.grouped)
        .frame(minHeight: dimensions.controlsSettingsMinimumHeight)
    }
}

#if DEBUG
#Preview {
    ControlsSettings(settingsViewModel: PreviewObjectPool.settingsViewModel)
}
#endif
