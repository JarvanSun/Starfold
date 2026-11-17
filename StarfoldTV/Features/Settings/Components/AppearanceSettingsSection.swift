//
//  AppearanceSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct AppearanceSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            ChoiceLink(
                "settings.appearance.palette",
                selection: $settingsViewModel.palette,
                choices: settingsViewModel.palettes
            ) { PaletteLabel($0) }
        } header: {
            Text("settings.appearance.header")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        AppearanceSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
