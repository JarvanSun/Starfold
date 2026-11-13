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
        Section("settings.controllers.header") {
            if settings.isControllerMissing {
                Text("controller.missing.instructions").foregroundStyle(.secondary)
            }

            ForEach(settings.connectedControllers) { row(for: $0) }

            Toggle("settings.controllers.rumble", isOn: $settings.isRumbleEnabled)
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settings.playerNumber(of: controller),
            batteryLevel: settings.batteryLevel(of: controller)
        )
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
