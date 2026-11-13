//
//  ConsolePowerButton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsolePowerButton: View {
    let control: ConsolePowerControl

    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            label
        }
        .buttonStyle(.circleIcon)
        .disabled(isDisabled)
        .help(help)
    }

    @ViewBuilder
    private var label: some View {
        switch control {
        case .command(let command): Label(command.title, systemImage: "power")
        case .sending: ProgressView().controlSize(.small)
        case .unavailable: Label(XboxLiveClient.PowerCommand.wakeUp.title, systemImage: "power")
        }
    }

    private var isDisabled: Bool {
        switch control {
        case .command: false
        case .sending, .unavailable: true
        }
    }

    private var help: Text {
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
