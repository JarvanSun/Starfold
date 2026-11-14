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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dimensions) private var dimensions
    @State private var isHovering = false
    @FocusState private var isFocused: Bool

    let console: Console
    let homeViewModel: HomeViewModel

    private var isLifted: Bool {
        isHovering && !reduceMotion
    }

    var body: some View {
        Button {
            play()
        } label: {
            card
        }
        .buttonStyle(.card)
        .hoverEffectDisabled()
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .contextMenu { powerMenu }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            Text("home.card.accessibilityLabel \(console.name) \(console.powerStateDescription)")
        )
    }

    private var card: some View {
        layout
            .frame(maxWidth: .infinity)
            .frame(height: dimensions.homeCardHeight(forVerticalSizeClass: verticalSizeClass))
            .cardSurface(highlighted: isFocused)
            .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
            .shadow(
                color: .black.opacity(isHovering ? 0.55 : 0.3),
                radius: isHovering ? dimensions.shadowRadiusLarge : dimensions.shadowRadiusMedium,
                y: isHovering ? dimensions.shadowOffsetLarge : dimensions.shadowOffsetMedium
            )
            .offset(y: isLifted ? -dimensions.spaceSmall : 0)
            .animation(.spring(duration: 0.35, bounce: 0.3), value: isHovering)
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .contentShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
            .onHover { isHovering = $0 }
    }

    @ViewBuilder
    private var layout: some View {
        switch verticalSizeClass {
        case .compact:
            HStack(spacing: 0) {
                artwork
                    .frame(width: dimensions.homeCardCompactArtworkWidth)
                    .frame(maxHeight: .infinity)
                    .clipped()

                information
            }
        default:
            VStack(spacing: 0) {
                artwork
                    .frame(maxWidth: .infinity)
                    .frame(height: dimensions.homeCardArtworkHeight)
                    .clipped()

                information
            }
        }
    }

    private var artwork: some View {
        let artworkHoverScale: CGFloat = 1.04

        return ConsoleCardArt(console: console, consoleCover: homeViewModel.cover(for: console))
            .scaleEffect(isLifted ? artworkHoverScale : 1)
    }

    private var information: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
                HStack(alignment: .firstTextBaseline) {
                    Text(console.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer(minLength: dimensions.spaceSmall)

                    statusDot
                }

                Text(console.modelName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: dimensions.spaceMedium)

            HStack(spacing: dimensions.spaceSmall) {
                ConsolePowerButton(
                    control: homeViewModel.powerControl(for: console),
                    onToggle: { togglePower() }
                )
                .focusable(false)

                if console.hasWirelessWarning {
                    wirelessHint
                }

                Spacer()

                playButton
            }
        }
        .padding(dimensions.spaceLarge)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var statusDot: some View {
        let status = homeViewModel.status(of: console)

        return StatusDot(color: status.color, pulsing: status.isPulsing)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(console.powerStateDescription))
    }

    private var wirelessHint: some View {
        Image(systemName: "wifi")
            .foregroundStyle(.secondary)
            .accessibilityLabel(Text("home.console.wirelessHint"))
    }

    private var playButton: some View {
        Button {
            play()
        } label: {
            Label("home.console.play", systemImage: "play.fill")
                .font(.callout.weight(.semibold))
        }
        .buttonStyle(PrimaryButtonStyle(size: .compact))
        .focusable(false)
        .help(Text("home.console.play"))
    }

    @ViewBuilder
    private var powerMenu: some View {
        switch homeViewModel.powerControl(for: console) {
        case .command(let command): powerMenuButton(for: command)
        case .sending(let command): powerMenuButton(for: command).disabled(true)
        case .unavailable: EmptyView()
        }
    }

    private func powerMenuButton(for command: XboxLiveClient.PowerCommand) -> some View {
        Button {
            togglePower()
        } label: {
            Label(command.title, systemImage: "power")
        }
    }

    private func play() {
        homeViewModel.play(console)
    }

    private func togglePower() {
        Task { await homeViewModel.togglePower(of: console) }
    }
}

#if DEBUG
#Preview {
    let homeViewModel = PreviewObjectPool.homeViewModel()
    return VStack {
        ForEach(PreviewObjectPool.consoles) { console in
            ConsoleCard(console: console, homeViewModel: homeViewModel)
        }
    }
    .frame(width: 360)
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif
