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
        Section("settings.controllers.title") {
            if settingsViewModel.isControllerMissing {
                Text("settings.controllers.empty")
                    .foregroundStyle(.secondary)
            }

            ForEach(settingsViewModel.connectedControllers) { row(for: $0) }

            if settingsViewModel.isXboxButtonTakenBySystem {
                xboxButtonRow
            }

            Toggle("settings.controllers.rumble", isOn: $settingsViewModel.isRumbleEnabled)
        }
    }

    private var xboxButtonRow: some View {
        LabeledContent {
            Button("settings.controllers.xboxButton.openSettings") {
                settingsViewModel.openXboxButtonSettings()
            }
        } label: {
            Text("settings.controllers.xboxButton.title")
            Text("settings.controllers.xboxButton.detail")
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settingsViewModel.playerNumber(of: controller),
            batteryLevel: settingsViewModel.batteryLevel(of: controller)
        ) {
            settingsViewModel.testRumble(on: controller)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
}
#endif
