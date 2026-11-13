//
//  ConsoleCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsoleCard: View {
    let console: Console
    let home: HomeViewModel

    var body: some View {
        HomeCard(heading: heading, primaryAction: playAction) {
            ConsoleCardArt(console: console, cover: home.cover(for: console))
        } actions: {
            ConsolePowerButton(
                control: home.powerControl(for: console),
                onToggle: { togglePower() }
            )

            if console.hasWirelessWarning {
                wirelessHint
            }
        }
    }

    private var heading: HomeCardHeading {
        let status = home.status(of: console)
        return .init(
            title: Text(console.name),
            subtitle: Text(console.modelName),
            status: .init(
                text: Text(console.powerStateDescription),
                color: status.color,
                isPulsing: status.isPulsing,
                isTextShown: false
            )
        )
    }

    private var playAction: HomeCardAction {
        .init(
            title: "home.console.play",
            systemImage: "play.fill",
            isEnabled: true,
            onPerform: { play() }
        )
    }

    private func play() {
        home.play(console)
    }

    private func togglePower() {
        Task { await home.togglePower(of: console) }
    }

    private var wirelessHint: some View {
        Image(systemName: "wifi")
            .foregroundStyle(.secondary)
            .accessibilityLabel(Text("home.console.wirelessHint"))
    }
}

#if DEBUG
#Preview {
    let home = PreviewObjectPool.homeViewModel()
    return VStack {
        ForEach(PreviewObjectPool.consoles) { console in
            ConsoleCard(console: console, home: home)
        }
    }
    .frame(width: 360)
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif
