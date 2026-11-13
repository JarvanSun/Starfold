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

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            LibrarySectionHeader(title: shelf.title, count: nil)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: dimensions.spaceLarge) {
                    ForEach(games) { tile(for: $0) }
                }
                .padding(.vertical, dimensions.spaceSmall)
            }
            .pageScrollMargins()
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
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
