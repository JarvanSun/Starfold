//
//  ShelfRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ShelfRow: View {
    @Environment(\.dimensions) private var dimensions

    let shelf: LibraryShelf
    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void
    let onOpen: (CloudGame) -> Void

    var firstTileFocus: FocusState<Bool>.Binding?

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            LibrarySectionHeader(title: shelf.title, count: nil)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: dimensions.spaceLarge) {
                    ForEach(games) { game in
                        focusTarget(tile(for: game), isFirst: game.id == games.first?.id)
                    }
                }
                .padding(.vertical, dimensions.spaceSmall)
            }
            .pageScrollMargins()
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private func focusTarget(_ tile: some View, isFirst: Bool) -> some View {
        switch (firstTileFocus, isFirst) {
        case (let focus?, true): tile.focused(focus)
        default: tile
        }
    }

    private func tile(for game: CloudGame) -> some View {
        GameTile(game: game, badge: shelf.badge) {
            onPlay(game)
        } onOpen: {
            onOpen(game)
        }
        .frame(width: dimensions.gameTileWidth)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        ForEach(LibraryShelf.allCases) { shelf in
            ShelfRow(shelf: shelf, games: PreviewObjectPool.cloudGames, onPlay: { _ in }) { _ in }
        }
    }
    .padding(.vertical)
    .environment(\.colorScheme, .dark)
}
#endif
