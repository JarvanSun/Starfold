//
//  AllGamesGrid.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct AllGamesGrid: View {
    @Environment(\.dimensions) private var dimensions
    let libraryViewModel: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var firstTileFocus: FocusState<Bool>.Binding?

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            LibrarySectionHeader(
                title: "library.allGames.title",
                count: libraryViewModel.sortedGames.count
            )

            GameGrid(
                games: libraryViewModel.sortedGames,
                onPlay: { libraryViewModel.play($0) },
                onOpen: { onOpenGame($0) },
                firstTileFocus: firstTileFocus
            )
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AllGamesGrid(libraryViewModel: PreviewObjectPool.libraryViewModel()) { _ in }
    }
    .environment(\.colorScheme, .dark)
}
#endif
