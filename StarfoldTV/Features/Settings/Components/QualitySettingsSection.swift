//
//  QualitySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct QualitySettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.quality.console.title", selection: $settings.consoleQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.consoleTitle).tag(choice)
                }
            }

            Picker("settings.quality.cloud.title", selection: $settings.cloudQuality) {
                ForEach(settings.qualityChoices, id: \.self) { choice in
                    Text(choice.cloudTitle).tag(choice)
                }
            }
        } header: {
            Text("settings.quality.header")
        } footer: {
            Text("settings.quality.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        QualitySettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
