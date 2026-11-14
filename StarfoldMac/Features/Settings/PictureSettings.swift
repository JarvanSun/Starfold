//
//  PictureSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettings: View {
    let settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            PictureSettingsSection(settingsViewModel: settingsViewModel)

            PacingSettingsSection(settingsViewModel: settingsViewModel)
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    PictureSettings(settingsViewModel: PreviewObjectPool.settingsViewModel)
}
#endif
