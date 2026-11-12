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

    let settings: SettingsViewModel

    var body: some View {
        Form {
            ControllerSettingsSection(settings: settings)

            KeyboardSettingsSection(settings: settings)
        }
        .formStyle(.grouped)
        .frame(minHeight: dimensions.controlsSettingsMinimumHeight)
    }
}

#if DEBUG
#Preview {
    ControlsSettings(settings: PreviewObjectPool.settingsViewModel)
}
#endif
