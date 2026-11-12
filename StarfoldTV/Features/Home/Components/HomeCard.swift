//
//  HomeCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct HomeCard<Picture: View>: View {
    @Environment(\.dimensions) private var dimensions

    let title: Text
    let subtitle: Text
    let status: Text
    let statusColor: Color
    let width: CGFloat
    let onSelect: () -> Void
    @ViewBuilder let picture: Picture

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                picture
                    .frame(width: width, height: dimensions.homeCardPictureHeight(width: width))
                    .clipped()

                caption
            }
        }
        .buttonStyle(.card)
    }
}

private extension HomeCard {
    var caption: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            HStack(spacing: dimensions.spaceMedium) {
                statusDot

                title.font(.callout.weight(.semibold)).lineLimit(1)
            }

            subtitle.font(.caption).foregroundStyle(.secondary).lineLimit(1, reservesSpace: true)
        }
        .padding(dimensions.spaceXLarge)
        .frame(width: width, alignment: .leading)
    }

    var statusDot: some View {
        Circle()
            .fill(statusColor)
            .frame(
                width: dimensions.homeCardStatusDotSize,
                height: dimensions.homeCardStatusDotSize
            )
            .accessibilityLabel(status)
    }
}

#if DEBUG
#Preview {
    let console = PreviewObjectPool.consoles[0]
    HomeCard(
        title: Text(console.name),
        subtitle: Text(console.modelName),
        status: Text(console.powerStateDescription),
        statusColor: ConsoleStatus.on.color,
        width: 480,
        onSelect: {},
        picture: { Artwork(url: PreviewObjectPool.cloudGames[0].product?.heroImage) }
    )
}
#endif
