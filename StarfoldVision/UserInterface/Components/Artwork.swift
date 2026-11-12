//
//  Artwork.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import XboxKit

struct Artwork: View {
    let url: URL?
    let aspectRatio: CGFloat

    var body: some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                AsyncImage(url: url, transaction: .init(animation: fadeIn)) { image(for: $0) }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

private extension Artwork {
    var fadeIn: Animation {
        .easeOut(duration: 0.3)
    }

    @ViewBuilder
    func image(for phase: AsyncImagePhase) -> some View {
        switch phase.image {
        case let image?: image.resizable().scaledToFill().transition(.opacity)
        case nil: Rectangle().fill(.thinMaterial)
        }
    }
}

#if DEBUG
#Preview("Artwork") {
    VStack {
        Artwork(url: PreviewObjectPool.cloudGames[1].product?.heroImage, aspectRatio: 16 / 9)

        Artwork(url: nil, aspectRatio: 16 / 9)
    }
    .frame(width: 640)
    .padding()
}
#endif
