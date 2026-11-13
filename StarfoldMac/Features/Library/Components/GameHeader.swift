//
//  GameHeader.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameHeader: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let detail: GameDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            Text(detail.name)
                .font(.system(size: dimensions.gameTitleSize, weight: .bold, design: .rounded))
                .shadow(color: .black.opacity(0.5), radius: dimensions.shadowRadiusMedium)

            HStack(spacing: dimensions.spaceLarge) {
                publisher

                ForEach(detail.inputs) { input in
                    Label(input.title, systemImage: input.symbol)
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            HStack(spacing: dimensions.spaceMedium) {
                playButton

                FavoriteButton(
                    action: detail.favoriteAction,
                    isFavorite: detail.isFavorite,
                    onToggle: { detail.toggleFavorite() }
                )
            }
        }
    }

    @ViewBuilder
    private var publisher: some View {
        switch (detail.publisher, detail.publisherInitial) {
        case (let publisher?, let initial?): publisherLabel(publisher, initial: initial)
        default: EmptyView()
        }
    }

    private func publisherLabel(_ publisher: String, initial: String) -> some View {
        HStack(spacing: dimensions.spaceSmall) {
            Text(initial)
                .font(.caption.bold())
                .frame(
                    width: dimensions.publisherMonogramSize,
                    height: dimensions.publisherMonogramSize
                )
                .background(
                    palette.primaryTint.opacity(0.85),
                    in: .rect(cornerRadius: dimensions.cornerRadiusSmall)
                )

            Text(publisher)
        }
    }

    private var playButton: some View {
        Button {
            detail.play()
        } label: {
            Label(String(localized: "gameDetail.play"), systemImage: "play.fill")
                .frame(minWidth: dimensions.gamePlayButtonMinimumWidth)
        }
        .buttonStyle(.primaryLarge)
        .keyboardShortcut(.defaultAction)
    }
}

#if DEBUG
#Preview {
    GameHeader(detail: PreviewObjectPool.gameDetailViewModel)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif
