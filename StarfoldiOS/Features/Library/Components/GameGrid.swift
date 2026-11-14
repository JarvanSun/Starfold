//
//  GameGrid.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameGrid: View {
    @Environment(\.dimensions) private var dimensions

    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void
    let onOpen: (CloudGame) -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: dimensions.spaceXLarge) {
            ForEach(games) { tile(for: $0) }
        }
        .pageMargins()
    }

    private var columns: [GridItem] {
        [
            .init(
                .adaptive(
                    minimum: dimensions.gameTileWidth,
                    maximum: dimensions.gameTileMaximumWidth
                ),
                spacing: dimensions.spaceLarge,
                alignment: .top
            )
        ]
    }

    private func tile(for game: CloudGame) -> some View {
        GameTile(game: game, badge: nil) {
            onPlay(game)
        } onOpen: {
            onOpen(game)
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        GameGrid(games: PreviewObjectPool.cloudGames, onPlay: { _ in }, onOpen: { _ in })
    }
    .environment(\.colorScheme, .dark)
}
#endif
