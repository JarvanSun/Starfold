//
//  RecentGamesRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
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
                .padding(.horizontal, dimensions.spaceXXXLarge)

            ScrollView(.horizontal) {
                LazyHStack(spacing: dimensions.spaceLarge) {
                    ForEach(games) { game in
                        RecentGameTile(game: game) { onPlay(game) }
                    }
                }
                .padding(.horizontal, dimensions.spaceXXXLarge)
                .padding(.vertical, dimensions.spaceSmall)
            }
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
