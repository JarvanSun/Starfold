//
//  SkeletonCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SkeletonCard: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            RoundedRectangle(cornerRadius: dimensions.cornerRadiusMedium)
                .fill(.white.opacity(0.06))
                .frame(height: dimensions.homeCardArtworkHeight - dimensions.spaceXLarge)

            RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                .fill(.white.opacity(0.10))
                .frame(width: dimensions.skeletonTitleWidth, height: dimensions.skeletonTitleHeight)

            RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                .fill(.white.opacity(0.07))
                .frame(
                    width: dimensions.skeletonSubtitleWidth,
                    height: dimensions.skeletonSubtitleHeight
                )

            HStack {
                Circle()
                    .fill(.white.opacity(0.07))
                    .frame(width: dimensions.circleButtonSize, height: dimensions.circleButtonSize)

                Spacer()

                Capsule()
                    .fill(.white.opacity(0.07))
                    .frame(
                        width: dimensions.skeletonButtonWidth,
                        height: dimensions.circleButtonSize
                    )
            }
        }
        .padding(dimensions.spaceMedium)
        .frame(width: dimensions.homeCardWidth, height: dimensions.homeCardHeight, alignment: .top)
        .shimmering()
        .cardSurface()
        .accessibilityLabel(Text("skeleton.loading.accessibilityLabel"))
    }
}

#if DEBUG
#Preview {
    SkeletonCard()
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif
