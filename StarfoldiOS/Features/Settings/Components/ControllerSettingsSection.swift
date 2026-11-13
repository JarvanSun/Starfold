//
//  ControllerSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct ControllerSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            if settings.isControllerMissing {
                Text("controller.missing.instructions").foregroundStyle(.secondary)
            }

            ForEach(settings.connectedControllers) { row(for: $0) }

            if settings.isXboxButtonTakenBySystem {
                xboxButtonRow
            }

            Toggle("settings.controllers.rumble", isOn: $settings.isRumbleEnabled)

            Toggle("settings.controllers.keyboard", isOn: $settings.isKeyboardControllerEnabled)
        } header: {
            Text("settings.controllers.header")
        } footer: {
            Text("settings.controllers.footer")
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
        ControllerSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
