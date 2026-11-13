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
    @Bindable var library: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            HStack {
                LibrarySectionHeader(
                    title: "library.allGames.title",
                    count: library.sortedGames.count
                )

                Spacer()

                SortPicker(sort: $library.sort, choices: library.sortChoices)
                    .pageMargins()
            }

            GameGrid(
                games: library.sortedGames,
                onPlay: { library.play($0) },
                onOpen: { onOpenGame($0) }
            )
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        AllGamesGrid(library: PreviewObjectPool.libraryViewModel()) { _ in }
    }
    .environment(\.colorScheme, .dark)
}
#endif
