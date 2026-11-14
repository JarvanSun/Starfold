//
//  ControlsSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct ControlsSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    let onEditTouchLayout: () -> Void

    var body: some View {
        Section("settings.controls.header") {
            if settingsViewModel.hasTouchControls {
                touchRows
            }

            if settingsViewModel.isControllerMissing {
                Text("controller.missing.instructions").foregroundStyle(.secondary)
            }

            ForEach(settingsViewModel.connectedControllers) { row(for: $0) }

            if settingsViewModel.isXboxButtonTakenBySystem {
                xboxButtonRow
            }

            Toggle("settings.controllers.rumble", isOn: $settingsViewModel.isRumbleEnabled)

            Toggle(
                "settings.controllers.keyboard",
                isOn: $settingsViewModel.isKeyboardControllerEnabled
            )
        }
    }

    private func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settingsViewModel.playerNumber(of: controller),
            batteryLevel: settingsViewModel.batteryLevel(of: controller)
        )
    }

    @ViewBuilder
    private var touchRows: some View {
        Button("settings.touch.editLayout") { onEditTouchLayout() }

        if settingsViewModel.canPlayTouchHaptics {
            Toggle("settings.touch.haptics", isOn: $settingsViewModel.isTouchHapticsEnabled)
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
}

#if DEBUG
#Preview {
    Form {
        ControlsSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel) {}
    }
}
#endif
