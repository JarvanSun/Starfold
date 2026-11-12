//
//  SoundSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SoundSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.sound.stage", selection: $settings.soundStage) {
                ForEach(settings.soundStages, id: \.self) { stage in
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
        SoundSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
