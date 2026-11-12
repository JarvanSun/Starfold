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
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                GameHero(artwork: detail.titledHeroArtwork)

                GameHeader(detail: detail)

                GameAbout(about: detail.about)

                GameFacts(facts: detail.facts)
            }
            .padding(dimensions.spaceHuge)
        }
        .scrollClipDisabled()
    }
}

#if DEBUG
#Preview {
    GameDetailView(detail: PreviewObjectPool.gameDetailViewModel)
}
#endif
