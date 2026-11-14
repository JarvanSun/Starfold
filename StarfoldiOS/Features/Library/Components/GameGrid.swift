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

    var firstTileFocus: FocusState<Bool>.Binding?

    var body: some View {
        LazyVGrid(columns: columns, spacing: dimensions.spaceXLarge) {
            ForEach(games) { game in
                focusTarget(tile(for: game), isFirst: game.id == games.first?.id)
            }
        }
        .pageMargins()
    }

    @ViewBuilder
    private func focusTarget(_ tile: some View, isFirst: Bool) -> some View {
        switch (firstTileFocus, isFirst) {
        case (let focus?, true): tile.focused(focus)
        default: tile
        }
    }

    private func tile(for game: CloudGame) -> some View {
        GameTile(game: game, badge: nil) {
            onPlay(game)
        } onOpen: {
            onOpen(game)
        }
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
}

#if DEBUG
#Preview {
    ScrollView {
        GameGrid(games: PreviewObjectPool.cloudGames, onPlay: { _ in }, onOpen: { _ in })
    }
    .environment(\.colorScheme, .dark)
}
#endif
