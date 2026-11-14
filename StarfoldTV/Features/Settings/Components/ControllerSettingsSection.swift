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
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section("settings.controllers.header") {
            if settingsViewModel.isControllerMissing {
                Text("controller.missing.instructions").foregroundStyle(.secondary)
            }

            ForEach(settingsViewModel.connectedControllers) { row(for: $0) }

            Toggle("settings.controllers.rumble", isOn: $settingsViewModel.isRumbleEnabled)
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settingsViewModel.playerNumber(of: controller),
            batteryLevel: settingsViewModel.batteryLevel(of: controller)
        )
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
