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
    let control: ConsolePowerControl
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            label
        }
        .buttonStyle(.circleIcon)
        .disabled(isDisabled)
        .help(help)
    }
}

private extension ConsolePowerButton {
    var wakeUp: XboxLiveClient.PowerCommand {
        .wakeUp
    }

    var isDisabled: Bool {
        switch control {
        case .command: false
        case .sending, .unavailable: true
        }
    }

    @ViewBuilder
    var label: some View {
        switch control {
        case .command(let command): Label(command.title, systemImage: "power")
        case .sending: ProgressView().controlSize(.small)
        case .unavailable: Label(wakeUp.title, systemImage: "power")
        }
    }

    var help: Text {
        switch control {
        case .command(let command), .sending(let command): Text(command.title)
        case .unavailable: Text("home.console.wakeUnavailable")
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        ConsolePowerButton(control: .command(.turnOff)) {}

        ConsolePowerButton(control: .command(.wakeUp)) {}

        ConsolePowerButton(control: .sending(.wakeUp)) {}

        ConsolePowerButton(control: .unavailable) {}
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif
