//
//  RecentGamesRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct RecentGamesRow: View {
    @Environment(\.dimensions) private var dimensions

    let games: [CloudGame]

    let onPlay: (CloudGame) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            Text("home.recentGames.title")
                .font(.title3.bold())
                .pageMargins()

            ScrollView(.horizontal) {
                LazyHStack(spacing: dimensions.spaceLarge) {
                    ForEach(games) { game in
                        RecentGameTile(game: game) { onPlay(game) }
                    }
                }
                .padding(.vertical, dimensions.spaceSmall)
            }
            .pageScrollMargins()
            .scrollIndicators(.hidden)
        }
    }
}

#if DEBUG
#Preview {
    RecentGamesRow(games: PreviewObjectPool.cloudGames) { _ in }
        .padding(.vertical)
        .environment(\.colorScheme, .dark)
}
#endif
