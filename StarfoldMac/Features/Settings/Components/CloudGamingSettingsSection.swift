//
//  CloudGamingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudGamingSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            Picker(
                String(localized: "settings.streaming.gameLanguage.title"),
                selection: $settings.gameLanguage
            ) {
                ForEach(settings.gameLanguages, id: \.self) { code in
                    Text(verbatim: settings.name(ofGameLanguage: code)).tag(code)
                }
            }
        } header: {
            Text("settings.streaming.cloudGaming.header")
        } footer: {
            Text("settings.streaming.cloudGaming.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        CloudGamingSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
