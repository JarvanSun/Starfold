//
//  GameTile.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameTile: View {
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @State private var isHovering = false

    let game: CloudGame
    let badge: LocalizedStringResource?

    let onPlay: () -> Void
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            artwork

            Text(game.name)
                .font(.callout.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(nameStyle)
        }
        .contentShape(.rect)
        .onHover { hover($0) }
        .onTapGesture { onOpen() }
        .contextMenu {
            Button(String(localized: "library.tile.play")) { onPlay() }

            Button(String(localized: "library.tile.showDetails")) { onOpen() }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text("library.tile.play"), onPlay)
        .accessibilityAction(.default, onOpen)
    }

    private func hover(_ isInside: Bool) {
        withAnimation(.spring(duration: 0.3, bounce: 0.35)) {
            isHovering = isInside
        }
    }

    private var artwork: some View {
        GameArtwork(url: game.tileArtwork, aspectRatio: 1)
            .overlay(if: badge, alignment: .topLeading) { badgeLabel($0) }
            .overlay(alignment: .bottomTrailing) {
                if isHovering {
                    playButton
                        .transition(playButtonTransition)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: dimensions.cornerRadiusMedium)
                    .strokeBorder(
                        .white.opacity(isHovering ? 0.35 : 0.08),
                        lineWidth: dimensions.hairline
                    )
            }
            .hoverLift(isHovering: isHovering)
    }

    private func badgeLabel(_ badge: LocalizedStringResource) -> some View {
        Text(badge)
            .font(.caption2.bold())
            .padding(.horizontal, dimensions.spaceSmall)
            .padding(.vertical, dimensions.spaceXSmall)
            .background(palette.primaryTint, in: .capsule)
            .foregroundStyle(.black)
            .padding(dimensions.spaceSmall)
    }

    private var playButton: some View {
        Button {
            onPlay()
        } label: {
            Label(String(localized: "library.tile.play"), systemImage: "play.fill")
                .labelStyle(.iconOnly)
                .frame(
                    width: dimensions.gameTilePlayIconSize,
                    height: dimensions.gameTilePlayIconSize
                )
        }
        .buttonStyle(.primary)
        .padding(dimensions.spaceSmall)
    }

    private var playButtonTransition: AnyTransition {
        switch reduceMotion {
        case true: .opacity
        case false: .scale(scale: 0.6).combined(with: .opacity)
        }
    }

    private var nameStyle: HierarchicalShapeStyle {
        switch isHovering {
        case true: .primary
        case false: .secondary
        }
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top) {
        ForEach(LibraryShelf.allCases) { shelf in
            GameTile(
                game: PreviewObjectPool.cloudGames[0],
                badge: shelf.badge,
                onPlay: {},
                onOpen: {}
            )
            .frame(width: 150)
        }
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif
