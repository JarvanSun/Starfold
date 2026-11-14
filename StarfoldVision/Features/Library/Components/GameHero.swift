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

    let gameDetailViewModel: GameDetailViewModel

    var body: some View {
        let scrimOpacity = 0.75

        ZStack(alignment: .bottomLeading) {
            Artwork(url: gameDetailViewModel.titledHeroArtwork, aspectRatio: aspectRatio)

            LinearGradient(
                colors: [.clear, .black.opacity(scrimOpacity)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
                Text(gameDetailViewModel.name)
                    .font(.extraLargeTitle2)
                    .lineLimit(2)

                badges

                actions
            }
            .padding(dimensions.spaceXXLarge)
        }
        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .padding(.horizontal, dimensions.spaceXLarge)
    }

    private var aspectRatio: CGFloat {
        16 / 7
    }

    private var badges: some View {
        HStack(spacing: dimensions.spaceLarge) {
            if let publisher = gameDetailViewModel.publisher {
                Text(publisher)
            }

            ForEach(gameDetailViewModel.inputs) { input in
                Label(input.title, systemImage: input.symbol)
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }

    private var actions: some View {
        HStack(spacing: dimensions.spaceMedium) {
            playButton

            FavoriteButton(
                action: gameDetailViewModel.favoriteAction,
                onToggle: { gameDetailViewModel.toggleFavorite() }
            )
        }
    }

    private var playButton: some View {
        Button {
            gameDetailViewModel.play()
        } label: {
            HStack(alignment: .center, spacing: dimensions.spaceSmall) {
                Image(systemName: "play.fill")

                Text("game.play")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#if DEBUG
#Preview("Game hero") {
    GameHero(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
        .padding()
}
#endif
