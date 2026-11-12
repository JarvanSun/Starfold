//
//  RecentGameTile.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct RecentGameTile: View {
    @Environment(\.dimensions) private var dimensions

    let game: CloudGame

    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
                GameArtwork(url: game.tileArtwork, aspectRatio: 1)

                Text(game.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: dimensions.recentGameTileWidth)
        }
        .buttonStyle(.tile)
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
