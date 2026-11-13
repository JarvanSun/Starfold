//
//  GameScreenshots.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameScreenshots: View {
    @Environment(\.dimensions) private var dimensions

    let screenshots: [URL]

    var body: some View {
        Shelf(title: "game.screenshots.title") {
            ForEach(screenshots, id: \.self) { url in
                Artwork(url: url, aspectRatio: aspectRatio)
                    .frame(height: dimensions.gameScreenshotHeight)
                    .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
            }
        }
    }

    private var aspectRatio: CGFloat {
        16 / 9
    }
}

#if DEBUG
#Preview("Game screenshots") {
    GameScreenshots(screenshots: PreviewObjectPool.gameDetailViewModel.screenshots)
        .padding()
}
#endif
