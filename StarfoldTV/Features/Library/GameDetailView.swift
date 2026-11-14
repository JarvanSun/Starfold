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
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                GameHero(artwork: gameDetailViewModel.titledHeroArtwork)

                GameHeader(gameDetailViewModel: gameDetailViewModel)

                GameAbout(about: gameDetailViewModel.about)

                GameFacts(facts: gameDetailViewModel.facts)
            }
            .padding(dimensions.spaceHuge)
        }
        .scrollClipDisabled()
    }
}

#if DEBUG
#Preview {
    GameDetailView(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
}
#endif
