//
//  GameShelf.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameShelf: View {
    let shelf: LibraryShelf
    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void

    var body: some View {
        Shelf(title: shelf.title) {
            ForEach(games) { game in
                GameLink(game: game) { onPlay(game) }
            }
        }
    }
}

#if DEBUG
#Preview("Game shelf") {
    NavigationStack {
        GameShelf(shelf: .recentlyAdded, games: PreviewObjectPool.cloudGames) { _ in }
            .padding()
    }
}
#endif
