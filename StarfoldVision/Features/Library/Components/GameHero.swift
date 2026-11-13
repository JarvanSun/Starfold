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

    let detail: GameDetailViewModel

    var body: some View {
        let scrimOpacity = 0.75

        ZStack(alignment: .bottomLeading) {
            Artwork(url: detail.titledHeroArtwork, aspectRatio: aspectRatio)

            LinearGradient(
                colors: [.clear, .black.opacity(scrimOpacity)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
                Text(detail.name)
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
}

private extension GameHero {
    var aspectRatio: CGFloat {
        16 / 7
    }

    var badges: some View {
        HStack(spacing: dimensions.spaceLarge) {
            switch detail.publisher {
            case let publisher?: Text(publisher)
            case nil: EmptyView()
            }

            ForEach(detail.inputs) { input in
                Label(input.title, systemImage: input.symbol)
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }

    var actions: some View {
        HStack(spacing: dimensions.spaceMedium) {
            playButton

            FavoriteButton(action: detail.favoriteAction, onToggle: { detail.toggleFavorite() })
        }
    }

    var playButton: some View {
        Button {
            detail.play()
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
    GameHero(detail: PreviewObjectPool.gameDetailViewModel)
        .padding()
}
#endif
