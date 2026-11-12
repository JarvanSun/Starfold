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
            Picker("settings.cloud.language.title", selection: $settings.gameLanguage) {
                ForEach(settings.gameLanguages, id: \.self) { code in
                    Text(verbatim: settings.name(ofGameLanguage: code)).tag(code)
                }
            }
        } header: {
            Text("settings.cloud.header")
        } footer: {
            Text("settings.cloud.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        CloudGamingSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
