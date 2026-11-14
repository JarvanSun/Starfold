//
//  KeyboardSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct KeyboardSettingsSection: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section(String(localized: "settings.controls.keyboard.title")) {
            Toggle(
                String(localized: "settings.controls.keyboard.asController"),
                isOn: $settingsViewModel.isKeyboardControllerEnabled
            )

            keyBindings
                .disabled(!settingsViewModel.isKeyboardControllerEnabled)
        }
    }

    private var keyBindings: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: dimensions.spaceLarge,
            verticalSpacing: dimensions.spaceXSmall
        ) {
            ForEach(settingsViewModel.keyBindings, id: \.key) { row(for: $0) }
        }
    }

    private func row(for binding: KeyBinding) -> some View {
        GridRow {
            Text(binding.key.name).font(.body.monospaced())

            Text(binding.control.name).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        KeyboardSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
