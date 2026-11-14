//
//  GameDetailView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
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
                .padding(.horizontal, dimensions.spaceXXLarge)
                .padding(.bottom, dimensions.spaceXXLarge)
                .offset(y: -dimensions.gameHeroOverlap)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .navigationTitle(gameDetailViewModel.name)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameDetailView(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
            .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}
#endif
