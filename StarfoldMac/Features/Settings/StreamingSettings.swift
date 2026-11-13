//
//  StreamingSettings.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamingSettings: View {
    let settings: SettingsViewModel

    var body: some View {
        Form {
            if settings.needsStreamRestart {
                RestartStreamSection(onRestart: { restartStream() })
            }

            QualitySettingsSection(settings: settings)

            CloudGamingSettingsSection(settings: settings)

            AppearanceSettingsSection(settings: settings)
        }
        .formStyle(.grouped)
    }

    private func restartStream() {
        Task { await settings.restartStream() }
    }
}

#if DEBUG
#Preview {
    StreamingSettings(settings: PreviewObjectPool.settingsViewModel)
}
#endif
