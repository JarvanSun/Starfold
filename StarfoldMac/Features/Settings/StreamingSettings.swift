//
//  StreamingSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamingSettings: View {
    let settingsViewModel: SettingsViewModel

    var body: some View {
        Form {
            if settingsViewModel.needsStreamRestart {
                RestartStreamSection(onRestart: { restartStream() })
            }

            QualitySettingsSection(settingsViewModel: settingsViewModel)

            CloudGamingSettingsSection(settingsViewModel: settingsViewModel)

            AppearanceSettingsSection(settingsViewModel: settingsViewModel)
        }
        .formStyle(.grouped)
    }

    private func restartStream() {
        Task { await settingsViewModel.restartStream() }
    }
}

#if DEBUG
#Preview {
    StreamingSettings(settingsViewModel: PreviewObjectPool.settingsViewModel)
}
#endif
