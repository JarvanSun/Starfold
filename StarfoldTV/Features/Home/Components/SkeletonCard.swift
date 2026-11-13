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

    let width: CGFloat

    var body: some View {
        let titleWidthRatio: CGFloat = 0.6
        let subtitleWidthRatio: CGFloat = 0.4

        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            RoundedRectangle(cornerRadius: dimensions.cornerRadiusLarge)
                .fill(Color.cardFill)
                .frame(
                    height: dimensions.homeCardPictureHeight(width: width) - dimensions.spaceXLarge
                )

            line(widthRatio: titleWidthRatio, height: dimensions.skeletonTitleLineHeight)

            line(widthRatio: subtitleWidthRatio, height: dimensions.skeletonTextLineHeight)
        }
        .padding(dimensions.spaceXLarge)
        .frame(width: width, height: dimensions.homeCardHeight(width: width))
        .cardSurface(cornerRadius: dimensions.cornerRadiusXLarge)
        .shimmering()
        .accessibilityLabel(Text("common.loading"))
    }
}

private extension SkeletonCard {
    func line(widthRatio: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
            .fill(Color.cardFill)
            .frame(width: width * widthRatio, height: height)
    }
}

#if DEBUG
#Preview {
    SkeletonCard(width: 480)
}
#endif
