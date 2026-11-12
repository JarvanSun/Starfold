//
//  GameHero.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameHero: View {
    @Environment(\.dimensions) private var dimensions

    let artwork: URL?

    var body: some View {
        Artwork(url: artwork)
            .frame(height: dimensions.gameHeroHeight)
            .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
    }
}

#if DEBUG
#Preview {
    GameHero(artwork: PreviewObjectPool.gameDetailViewModel.titledHeroArtwork)
}
#endif
