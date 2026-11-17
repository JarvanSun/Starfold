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
            ChoiceLink(
                "settings.cloud.language.title",
                selection: $settingsViewModel.gameLanguage,
                choices: settingsViewModel.gameLanguages
            ) { Text(verbatim: settingsViewModel.name(ofGameLanguage: $0)) }
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
