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
    @Environment(\.dimensions) private var dimensions

    let game: CloudGame

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            Artwork(url: game.tileArtwork, aspectRatio: 1)
                .frame(width: dimensions.gameTileWidth, height: dimensions.gameTileWidth)
                .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
                .hoverEffect(.highlight)

            Text(game.name)
                .font(.callout)
                .lineLimit(2, reservesSpace: true)
                .frame(width: dimensions.gameTileWidth, alignment: .leading)
        }
    }
}

#if DEBUG
#Preview("Game tiles") {
    HStack(alignment: .top) {
        ForEach(PreviewObjectPool.cloudGames.prefix(4)) { game in
            GameTile(game: game)
        }
    }
    .padding()
}
#endif
