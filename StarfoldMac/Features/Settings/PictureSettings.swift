//
//  PictureSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettings: View {
    let settings: SettingsViewModel

    var body: some View {
        Form {
            PictureSettingsSection(settings: settings)

            PacingSettingsSection(settings: settings)
        }
        .formStyle(.grouped)
    }
}

#if DEBUG
#Preview {
    PictureSettings(settings: PreviewObjectPool.settingsViewModel)
}
#endif
