//
//  GameGrid.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameGrid: View {
    @Environment(\.dimensions) private var dimensions

    let games: [CloudGame]

    var body: some View {
        LazyVGrid(columns: columns, spacing: dimensions.spaceXXXLarge) {
            ForEach(games) { GameLink(game: $0) }
        }
    }

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: dimensions.gameTileMinimumWidth),
                spacing: dimensions.spaceXXLarge
            )
        ]
    }
}

#if DEBUG
#Preview {
    GameGrid(games: PreviewObjectPool.cloudGames)
}
#endif
