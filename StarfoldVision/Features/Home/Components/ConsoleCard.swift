//
//  ConsoleCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsoleCard: View {
    @Environment(\.dimensions) private var dimensions

    let console: Console
    let home: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ConsoleCardArtwork(console: console, cover: home.cover(for: console))

            VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
                summary

                actions
            }
            .padding(dimensions.spaceXLarge)
        }
        .frame(
            width: dimensions.consoleCardWidth,
            height: dimensions.consoleCardHeight,
            alignment: .top
        )
        .background(.regularMaterial, in: .rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .hoverEffect(.highlight)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXSmall) {
            Text(console.name)
                .font(.title3.bold())
                .lineLimit(1)

            HStack(spacing: dimensions.spaceSmall) {
                statusDot

                Text(console.modelName)
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }

    private var statusDot: some View {
        let status = home.status(of: console)
        return StatusDot(color: status.color, pulsing: status.isPulsing)
            .accessibilityLabel(Text(console.powerStateDescription))
    }

    private var actions: some View {
        HStack(spacing: dimensions.spaceMedium) {
            playButton

            ConsolePowerButton(
                control: home.powerControl(for: console),
                onToggle: { togglePower() }
            )

            Spacer(minLength: 0)

            if console.hasWirelessWarning {
                wirelessWarning
            }
        }
    }

    private var playButton: some View {
        Button {
            play()
        } label: {
            HStack(alignment: .center, spacing: dimensions.spaceSmall) {
                Image(systemName: "play.fill")

                Text("home.console.play")
            }
        }
        .buttonStyle(.borderedProminent)
    }

    private func play() {
        home.play(console)
    }

    private func togglePower() {
        Task { await home.togglePower(of: console) }
    }

    private var wirelessWarning: some View {
        Image(systemName: "wifi")
            .foregroundStyle(.secondary)
            .accessibilityLabel(Text("home.console.wirelessWarning"))
    }
}

#if DEBUG
#Preview("Console cards") {
    let home = PreviewObjectPool.homeViewModel()

    HStack {
        ForEach(PreviewObjectPool.consoles) { console in
            ConsoleCard(console: console, home: home)
        }
    }
    .padding()
}
#endif
