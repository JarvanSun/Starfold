//
//  DisplaySettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct DisplaySettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section("settings.display.header") {
            Picker("settings.picture.mode.title", selection: $settings.pictureFit) {
                ForEach(settings.pictureFits, id: \.self) { fit in
                    Text(fit.title).tag(fit)
                }
            }

            Toggle("settings.picture.statistics", isOn: $settings.shouldShowStatistics)

            PalettePicker(selection: $settings.palette)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        DisplaySettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
