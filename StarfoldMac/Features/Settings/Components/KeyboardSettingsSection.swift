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
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section(String(localized: "settings.controls.keyboard.title")) {
            Toggle(
                String(localized: "settings.controls.keyboard.asController"),
                isOn: $settings.isKeyboardControllerEnabled
            )

            keyBindings
                .disabled(!settings.isKeyboardControllerEnabled)
        }
    }
}

private extension KeyboardSettingsSection {
    var keyBindings: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: dimensions.spaceLarge,
            verticalSpacing: dimensions.spaceXSmall
        ) {
            ForEach(settings.keyBindings, id: \.key) { row(for: $0) }
        }
    }

    func row(for binding: KeyBinding) -> some View {
        GridRow {
            Text(binding.key.name).font(.body.monospaced())

            Text(binding.control.name).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        KeyboardSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
