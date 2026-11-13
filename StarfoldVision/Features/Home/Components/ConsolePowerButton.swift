//
//  ConsolePowerButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsolePowerButton: View {
    @Environment(\.dimensions) private var dimensions

    let control: ConsolePowerControl

    let onToggle: () -> Void

    var body: some View {
        switch control {
        case .command(let command): button(for: command)
        case .sending: progress
        case .unavailable: EmptyView()
        }
    }

    private func button(for command: XboxLiveClient.PowerCommand) -> some View {
        Button {
            onToggle()
        } label: {
            Label(command.title, systemImage: "power")
        }
        .labelStyle(.iconOnly)
        .buttonBorderShape(.circle)
        .help(Text(command.title))
    }

    private var progress: some View {
        ProgressView()
            .frame(
                width: dimensions.consolePowerButtonSize,
                height: dimensions.consolePowerButtonSize
            )
    }
}

#if DEBUG
#Preview("Power buttons") {
    HStack {
        ConsolePowerButton(control: .command(.turnOff)) {}

        ConsolePowerButton(control: .command(.wakeUp)) {}

        ConsolePowerButton(control: .sending(.wakeUp)) {}

        ConsolePowerButton(control: .unavailable) {}
    }
    .padding()
}
#endif
