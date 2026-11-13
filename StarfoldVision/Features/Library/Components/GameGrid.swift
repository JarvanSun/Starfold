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

    let title: LocalizedStringResource
    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            header

            LazyVGrid(columns: columns, alignment: .leading, spacing: dimensions.spaceXLarge) {
                ForEach(games) { game in
                    GameLink(game: game) { onPlay(game) }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: dimensions.spaceSmall) {
            Text(title)
                .font(.title2.bold())

            Text(games.count, format: .number)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private var columns: [GridItem] {
        [
            .init(
                .adaptive(
                    minimum: dimensions.gameTileWidth,
                    maximum: dimensions.gameGridColumnMaximumWidth
                ),
                spacing: dimensions.spaceXLarge,
                alignment: .top
            )
        ]
    }
}

#if DEBUG
#Preview("Game grid") {
    NavigationStack {
        ScrollView {
            GameGrid(
                title: PreviewObjectPool.libraryViewModel().gamesTitle,
                games: PreviewObjectPool.cloudGames
            ) { _ in }
            .padding()
        }
    }
}
#endif
