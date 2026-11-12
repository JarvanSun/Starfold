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

    let detail: GameDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                GameHero(detail: detail)

                GameOverview(about: detail.about, facts: detail.facts)
                    .padding(.horizontal, dimensions.spaceXXLarge)

                if !detail.screenshots.isEmpty {
                    GameScreenshots(screenshots: detail.screenshots)
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
        GameDetailView(detail: PreviewObjectPool.gameDetailViewModel)
    }
}
#endif
