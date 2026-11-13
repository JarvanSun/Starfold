//
//  ControllerRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ControllerRow: View {
    let name: String
    let playerNumber: Int
    let batteryLevel: Double?

    let onTestVibration: () -> Void

    var body: some View {
        HStack {
            Label(name, systemImage: "gamecontroller.fill")

            Spacer()

            Text("settings.controllers.player \(playerNumber)")
                .foregroundStyle(.secondary)

            battery

            Button("settings.controllers.testVibration") { onTestVibration() }
        }
    }

    @ViewBuilder
    private var battery: some View {
        switch batteryLevel {
        case let level?:
            Text(level, format: .percent.precision(.fractionLength(0)))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        case nil:
            EmptyView()
        }
    }
}

#if DEBUG
#Preview {
    Form {
        ControllerRow(name: "Xbox Wireless Controller", playerNumber: 1, batteryLevel: 0.8) {}

        ControllerRow(name: "DualSense Wireless Controller", playerNumber: 2, batteryLevel: nil) {}
    }
}
#endif
