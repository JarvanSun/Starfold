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
        Section(String(localized: "settings.controls.controllers.title")) {
            if settingsViewModel.isControllerMissing {
                Text("settings.controls.controllers.empty")
                    .foregroundStyle(.secondary)
            }

            ForEach(settingsViewModel.connectedControllers) { row(for: $0) }

            if settingsViewModel.isXboxButtonTakenBySystem {
                xboxButtonRow
            }

            Toggle(
                String(localized: "settings.controls.rumble"),
                isOn: $settingsViewModel.isRumbleEnabled
            )
        }
    }

    private var xboxButtonRow: some View {
        LabeledContent {
            Button(String(localized: "settings.controls.xboxButton.openSettings")) {
                settingsViewModel.openXboxButtonSettings()
            }
        } label: {
            Text("settings.controls.xboxButton.title")
            Text("settings.controls.xboxButton.detail")
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settingsViewModel.playerNumber(of: controller)
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
    .formStyle(.grouped)
}
#endif
