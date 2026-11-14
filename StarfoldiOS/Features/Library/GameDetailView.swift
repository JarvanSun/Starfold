//
//  GameDetailView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct GameDetailView: View {
    @Environment(\.dimensions) private var dimensions

    let gameDetailViewModel: GameDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GameHero(artwork: gameDetailViewModel.heroArtwork)

                VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                    GameHeader(gameDetailViewModel: gameDetailViewModel)

                    GameOverview(about: gameDetailViewModel.about, facts: gameDetailViewModel.facts)

                    if !gameDetailViewModel.screenshots.isEmpty {
                        GameScreenshots(screenshots: gameDetailViewModel.screenshots)
                    }
                }
                .pageMargins()
                .padding(.bottom, dimensions.spaceXXLarge)
                .offset(y: -dimensions.gameHeroOverlap)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .navigationTitle(gameDetailViewModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameDetailView(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif
