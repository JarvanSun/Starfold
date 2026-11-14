//
//  GameTile.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameTile: View {
    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @State private var isHovering = false
    @FocusState private var isFocused: Bool

    let game: CloudGame
    let badge: LocalizedStringResource?

    let onPlay: () -> Void
    let onOpen: () -> Void

    var body: some View {
        Button {
            onOpen()
        } label: {
            label
        }
        .buttonStyle(.card)
        .hoverEffectDisabled()
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .contextMenu {
            Button(String(localized: "library.tile.play")) { onPlay() }

            Button(String(localized: "library.tile.showDetails")) { onOpen() }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: Text("library.tile.play"), onPlay)
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            artwork

            Text(game.name)
                .font(.callout.weight(.medium))
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(nameStyle)
        }
        .contentShape(.rect)
        .onHover { hover($0) }
    }

    private var isLifted: Bool {
        isHovering || isFocused
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
                    .strokeBorder(border, lineWidth: borderWidth)
            }
            .hoverLift(isHovering: isLifted)
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
        .focusable(false)
        .padding(dimensions.spaceSmall)
    }

    private var border: AnyShapeStyle {
        switch (isFocused, isHovering) {
        case (true, _): .init(palette.primaryFill)
        case (false, true): .init(.white.opacity(0.35))
        case (false, false): .init(.white.opacity(0.08))
        }
    }

    private var borderWidth: CGFloat {
        isFocused ? dimensions.highlightBorderWidth : dimensions.hairline
    }

    private var playButtonTransition: AnyTransition {
        switch reduceMotion {
        case true: .opacity
        case false: .scale(scale: 0.6).combined(with: .opacity)
        }
    }

    private var nameStyle: HierarchicalShapeStyle {
        switch isLifted {
        case true: .primary
        case false: .secondary
        }
    }

    private func hover(_ isInside: Bool) {
        withAnimation(.spring(duration: 0.3, bounce: 0.35)) {
            isHovering = isInside
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
