//
//  GameLink.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameLink: View {
    @Environment(\.dimensions) private var dimensions

    let game: CloudGame
    var artworkHeight: CGFloat?
    var titleLines = 2

    var body: some View {
        NavigationLink(value: game) {
            VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
                Artwork(url: game.tileArtwork)
                    .frame(height: artworkFrameHeight)
                    .clipShape(.rect(cornerRadius: dimensions.cornerRadiusLarge))

                Text(game.name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(titleLines, reservesSpace: true)
            }
            .padding(dimensions.spaceMedium)
        }
        .buttonStyle(.card)
    }
}

private extension GameLink {
    var artworkFrameHeight: CGFloat {
        artworkHeight ?? dimensions.gameArtworkHeight
    }
}

#if DEBUG
#Preview {
    HStack {
        GameLink(game: PreviewObjectPool.cloudGames[0])

        GameLink(
            game: PreviewObjectPool.cloudGames[1],
            artworkHeight: Dimensions().gameShelfArtworkMaximumHeight,
            titleLines: 1
        )
    }
}
#endif
