//
//  RecentGameTile.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct RecentGameTile: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions
    @FocusState private var isFocused: Bool

    let game: CloudGame

    let onPlay: () -> Void

    var body: some View {
        Button {
            onPlay()
        } label: {
            VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
                GameArtwork(url: game.tileArtwork, aspectRatio: 1)
                    .overlay {
                        RoundedRectangle(cornerRadius: dimensions.cornerRadiusMedium)
                            .strokeBorder(
                                palette.primaryFill,
                                lineWidth: dimensions.highlightBorderWidth
                            )
                            .opacity(isFocused ? 1 : 0)
                    }

                Text(game.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: true)
            }
            .frame(width: dimensions.recentGameTileWidth)
        }
        .buttonStyle(.tile)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .help(Text("home.recentGames.play \(game.name)"))
        .accessibilityLabel(Text("home.recentGames.play \(game.name)"))
    }
}

#if DEBUG
#Preview {
    RecentGameTile(game: PreviewObjectPool.cloudGames[0]) {}
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif
