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
    @Bindable var settings: SettingsViewModel

    let onEditTouchLayout: () -> Void

    var body: some View {
        Section("settings.controls.header") {
            if settings.hasTouchControls {
                touchRows
            }

            if settings.isControllerMissing {
                Text("controller.missing.instructions").foregroundStyle(.secondary)
            }

            ForEach(settings.connectedControllers) { row(for: $0) }

            if settings.isXboxButtonTakenBySystem {
                xboxButtonRow
            }

            Toggle("settings.controllers.rumble", isOn: $settings.isRumbleEnabled)

            Toggle("settings.controllers.keyboard", isOn: $settings.isKeyboardControllerEnabled)
        }
    }

    @ViewBuilder
    private var touchRows: some View {
        Button("settings.touch.editLayout") { onEditTouchLayout() }

        if settings.canPlayTouchHaptics {
            Toggle("settings.touch.haptics", isOn: $settings.isTouchHapticsEnabled)
        }
    }

    private var xboxButtonRow: some View {
        LabeledContent {
            Button("settings.controllers.xboxButton.openSettings") {
                settings.openXboxButtonSettings()
            }
        } label: {
            Text("settings.controllers.xboxButton.title")
            Text("settings.controllers.xboxButton.detail")
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
        ControlsSettingsSection(settings: PreviewObjectPool.settingsViewModel) {}
    }
}
#endif
