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

    let detail: GameDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GameHero(artwork: detail.heroArtwork)

                VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
                    GameHeader(detail: detail)

                    GameOverview(about: detail.about, facts: detail.facts)

                    if !detail.screenshots.isEmpty {
                        GameScreenshots(screenshots: detail.screenshots)
                    }
                }
                .padding(.horizontal, dimensions.spaceXXLarge)
                .padding(.bottom, dimensions.spaceXXLarge)
                .offset(y: -dimensions.gameHeroOverlap)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .navigationTitle(detail.name)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameDetailView(detail: PreviewObjectPool.gameDetailViewModel)
            .background { SkyBackground() }
    }
    .frame(width: 1180, height: 820)
    .environment(\.colorScheme, .dark)
}
#endif
