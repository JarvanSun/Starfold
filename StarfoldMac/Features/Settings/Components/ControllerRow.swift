//
//  ControllerRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ControllerRow: View {
    @Environment(\.dimensions) private var dimensions

    let name: String
    let playerNumber: Int
    let onTestVibration: () -> Void

    var body: some View {
        LabeledContent(name) {
            HStack(spacing: dimensions.spaceMedium) {
                Text("settings.controls.controller.player \(playerNumber)")

                Button(
                    String(localized: "settings.controls.controller.testVibration"),
                    action: onTestVibration
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerRow(name: "Xbox Wireless Controller", playerNumber: 1) {}

        ControllerRow(name: "DualSense Wireless Controller", playerNumber: 2) {}
    }
    .formStyle(.grouped)
}
#endif
