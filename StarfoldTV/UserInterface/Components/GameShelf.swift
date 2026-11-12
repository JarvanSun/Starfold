//
//  GameShelf.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameShelf: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    let games: [CloudGame]
    var tileWidth: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            Text(title).font(.headline)

            ScrollView(.horizontal) {
                LazyHStack(spacing: dimensions.spaceXXLarge) {
                    ForEach(games) { tile($0) }
                }
                .padding(.vertical, dimensions.spaceLarge)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .focusSection()
        }
    }
}

private extension GameShelf {
    var tileFrameWidth: CGFloat {
        tileWidth ?? dimensions.gameShelfTileWidth
    }

    var artworkHeight: CGFloat {
        min(dimensions.gameShelfArtworkMaximumHeight, tileFrameWidth * 9 / 16)
    }

    func tile(_ game: CloudGame) -> some View {
        GameLink(game: game, artworkHeight: artworkHeight, titleLines: 1)
            .frame(width: tileFrameWidth)
    }
}

#if DEBUG
#Preview {
    GameShelf(title: "home.recentlyPlayed.title", games: PreviewObjectPool.cloudGames)
}
#endif
