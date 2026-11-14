//
//  SoundSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SoundSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.sound.stage", selection: $settingsViewModel.soundStage) {
                ForEach(settingsViewModel.soundStages, id: \.self) { stage in
                    Text(stage.title).tag(stage)
                }
            }
        } header: {
            Text("settings.sound.title")
        } footer: {
            Text("settings.sound.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SoundSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
