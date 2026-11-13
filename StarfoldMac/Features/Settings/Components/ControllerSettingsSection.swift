//
//  ControllerSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct ControllerSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section(String(localized: "settings.controls.controllers.title")) {
            if settings.isControllerMissing {
                Text("settings.controls.controllers.empty")
                    .foregroundStyle(.secondary)
            }

            ForEach(settings.connectedControllers) { row(for: $0) }

            Toggle(String(localized: "settings.controls.rumble"), isOn: $settings.isRumbleEnabled)
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(name: controller.name, playerNumber: settings.playerNumber(of: controller)) {
            settings.testRumble(on: controller)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
