//
//  AllGamesGrid.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct AllGamesGrid: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var libraryViewModel: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            HStack {
                LibrarySectionHeader(
                    title: libraryViewModel.gamesTitle,
                    count: libraryViewModel.visibleGames.count
                )

                Spacer()

                SortPicker(sort: $libraryViewModel.sort, choices: libraryViewModel.sortChoices)
                    .padding(.trailing, dimensions.spaceXXLarge)
            }

            LazyVGrid(columns: columns, spacing: dimensions.spaceXLarge) {
                ForEach(libraryViewModel.visibleGames) { tile(for: $0) }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
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

    private func tile(for game: CloudGame) -> some View {
        GameTile(game: game, badge: nil) {
            libraryViewModel.play(game)
        } onOpen: {
            onOpenGame(game)
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AllGamesGrid(libraryViewModel: PreviewObjectPool.libraryViewModel()) { _ in }
    }
    .frame(width: 900, height: 600)
    .environment(\.colorScheme, .dark)
}
#endif
