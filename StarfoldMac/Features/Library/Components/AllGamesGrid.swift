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
    @Bindable var library: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            HStack {
                LibrarySectionHeader(title: library.gamesTitle, count: library.visibleGames.count)

                Spacer()

                SortPicker(sort: $library.sort, choices: library.sortChoices)
                    .padding(.trailing, dimensions.spaceXXLarge)
            }

            LazyVGrid(columns: columns, spacing: dimensions.spaceXLarge) {
                ForEach(library.visibleGames) { tile(for: $0) }
            }
            .padding(.horizontal, dimensions.spaceXXLarge)
        }
    }
}

private extension AllGamesGrid {
    var columns: [GridItem] {
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

    func tile(for game: CloudGame) -> some View {
        GameTile(game: game, badge: nil) {
            library.play(game)
        } onOpen: {
            onOpenGame(game)
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AllGamesGrid(library: PreviewObjectPool.libraryViewModel()) { _ in }
    }
    .frame(width: 900, height: 600)
    .environment(\.colorScheme, .dark)
}
#endif
