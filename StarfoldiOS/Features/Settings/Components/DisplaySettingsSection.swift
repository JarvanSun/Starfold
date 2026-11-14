//
//  DisplaySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct DisplaySettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section("settings.display.header") {
            Picker("settings.picture.mode.title", selection: $settingsViewModel.pictureFit) {
                ForEach(settingsViewModel.pictureFits, id: \.self) { fit in
                    Text(fit.title).tag(fit)
                }
            }

            Toggle("settings.picture.statistics", isOn: $settingsViewModel.shouldShowStatistics)

            PalettePicker(selection: $settingsViewModel.palette)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        DisplaySettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
