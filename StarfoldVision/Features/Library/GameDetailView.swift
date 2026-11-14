//
//  GameDetailView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct GameDetailView: View {
    @Environment(\.dimensions) private var dimensions

    let gameDetailViewModel: GameDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                GameHero(gameDetailViewModel: gameDetailViewModel)

                GameOverview(about: gameDetailViewModel.about, facts: gameDetailViewModel.facts)
                    .padding(.horizontal, dimensions.spaceXXLarge)

                if !gameDetailViewModel.screenshots.isEmpty {
                    GameScreenshots(screenshots: gameDetailViewModel.screenshots)
                        .padding(.horizontal, dimensions.spaceXXLarge)
                }
            }
            .padding(.bottom, dimensions.spaceXXLarge)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("Game") {
    NavigationStack {
        GameDetailView(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
    }
}
#endif
