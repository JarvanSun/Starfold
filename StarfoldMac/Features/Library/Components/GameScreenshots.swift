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
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text("gameDetail.screenshots.title")
                .font(.title3.bold())

            ScrollView(.horizontal) {
                LazyHStack(spacing: dimensions.spaceMedium) {
                    ForEach(screenshots, id: \.self) { url in
                        GameArtwork(url: url, aspectRatio: 16 / 9)
                            .frame(height: dimensions.gameScreenshotHeight)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}

#if DEBUG
#Preview {
    GameScreenshots(screenshots: PreviewObjectPool.gameDetailViewModel.screenshots)
        .padding()
        .environment(\.colorScheme, .dark)
}
#endif
