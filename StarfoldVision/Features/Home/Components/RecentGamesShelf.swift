//
//  RecentGamesShelf.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct RecentGamesShelf: View {
    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void

    var body: some View {
        Shelf(title: "home.recentGames.title") {
            ForEach(games) { button(for: $0) }
        }
    }

    private func button(for game: CloudGame) -> some View {
        Button {
            onPlay(game)
        } label: {
            GameTile(game: game)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("home.recentGames.play \(game.name)"))
    }
}

#if DEBUG
#Preview("Recent games") {
    RecentGamesShelf(games: PreviewObjectPool.cloudGames) { _ in }
        .padding()
}
#endif
