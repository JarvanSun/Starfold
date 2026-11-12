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

    let artwork: URL?

    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .scrollView).minY
            AsyncImage(
                url: artwork,
                transaction: .init(animation: .easeOut(duration: 0.4)),
                content: image(for:)
            )
            .frame(width: proxy.size.width, height: proxy.size.height + max(0, minY))
            .offset(y: offset(scrolledBy: minY))
            .clipped()
            .mask { fade }
        }
        .frame(height: dimensions.gameHeroHeight)
        .accessibilityHidden(true)
    }
}

private extension GameHero {
    var parallaxRate: CGFloat {
        0.35
    }

    var fade: LinearGradient {
        .init(
            stops: [
                .init(color: .black, location: 0.45),
                .init(color: .black.opacity(0.35), location: 0.8),
                .init(color: .clear, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    func image(for phase: AsyncImagePhase) -> some View {
        switch phase.image {
        case let image?: image.resizable().scaledToFill().transition(.opacity)
        case nil: Color.clear
        }
    }

    func offset(scrolledBy minY: CGFloat) -> CGFloat {
        switch minY > 0 {
        case true: -minY
        case false: -minY * parallaxRate
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        GameHero(artwork: PreviewObjectPool.gameDetailViewModel.heroArtwork)
    }
    .background { SkyBackground() }
    .frame(width: 900, height: 500)
    .environment(\.colorScheme, .dark)
}
#endif
