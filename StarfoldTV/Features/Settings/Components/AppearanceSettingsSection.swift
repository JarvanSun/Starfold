//
//  AppearanceSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct AppearanceSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            PalettePicker(selection: $settings.palette)
        } header: {
            Text("settings.appearance.header")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        AppearanceSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
