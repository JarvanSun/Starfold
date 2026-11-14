//
//  CloudGamingSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct CloudGamingSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            Picker("settings.cloud.language.title", selection: $settingsViewModel.gameLanguage) {
                ForEach(settingsViewModel.gameLanguages, id: \.self) { code in
                    Text(verbatim: settingsViewModel.name(ofGameLanguage: code)).tag(code)
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
        CloudGamingSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
