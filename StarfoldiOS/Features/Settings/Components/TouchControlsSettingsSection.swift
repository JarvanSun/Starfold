//
//  TouchControlsSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchControlsSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    let onEditLayout: () -> Void

    var body: some View {
        Section {
            Button("settings.touch.editLayout") { onEditLayout() }

            if settings.canPlayTouchHaptics {
                Toggle("settings.touch.haptics", isOn: $settings.isTouchHapticsEnabled)
            }
        } header: {
            Text("settings.touch.header")
        } footer: {
            Text("settings.touch.footer")
        }
    }
}

#if DEBUG
#Preview {
    Form {
        TouchControlsSettingsSection(settings: PreviewObjectPool.settingsViewModel) {}
    }
}
#endif
