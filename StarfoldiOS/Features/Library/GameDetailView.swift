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
                .pageMargins()
                .padding(.bottom, dimensions.spaceXXLarge)
                .offset(y: -dimensions.gameHeroOverlap)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .navigationTitle(detail.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameDetailView(detail: PreviewObjectPool.gameDetailViewModel)
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif
