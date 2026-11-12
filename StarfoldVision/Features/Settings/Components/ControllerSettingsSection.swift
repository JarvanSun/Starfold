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
        Section("settings.controllers.title") {
            if settings.isControllerMissing {
                Text("settings.controllers.empty")
                    .foregroundStyle(.secondary)
            }

            ForEach(settings.connectedControllers, content: row(for:))

            Toggle("settings.controllers.rumble", isOn: $settings.isRumbleEnabled)
        }
    }
}

private extension ControllerSettingsSection {
    func row(for controller: ConnectedController) -> some View {
        ControllerRow(
            name: controller.name,
            playerNumber: settings.playerNumber(of: controller),
            batteryLevel: settings.batteryLevel(of: controller)
        ) {
            settings.testRumble(on: controller)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
}
#endif
