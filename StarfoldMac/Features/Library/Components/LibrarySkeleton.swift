//
//  LibrarySkeleton.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibrarySkeleton: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                .fill(.white.opacity(0.10))
                .frame(width: dimensions.skeletonTitleWidth, height: dimensions.skeletonTitleHeight)

            HStack(spacing: dimensions.spaceLarge) {
                ForEach(0..<tileCount, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: dimensions.cornerRadiusMedium)
                        .fill(.white.opacity(0.06))
                        .frame(width: dimensions.gameTileWidth, height: dimensions.gameTileWidth)
                }
            }
        }
        .padding(dimensions.spaceXXLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .shimmering()
        .accessibilityLabel(Text("skeleton.loading.accessibilityLabel"))
    }
}

private extension LibrarySkeleton {
    var tileCount: Int {
        6
    }
}
