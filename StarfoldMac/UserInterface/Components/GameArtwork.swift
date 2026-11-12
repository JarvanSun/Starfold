//
//  GameArtwork.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameArtwork: View {
    @Environment(\.dimensions) private var dimensions

    let url: URL?
    let aspectRatio: CGFloat

    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.06))
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                AsyncImage(url: url, transaction: .init(animation: .easeOut(duration: 0.3))) {
                    image(for: $0)
                }
            }
            .clipShape(.rect(cornerRadius: dimensions.cornerRadiusMedium))
    }
}

private extension GameArtwork {
    @ViewBuilder
    func image(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .success(let image): image.resizable().scaledToFill().transition(.opacity)
        case .failure:
            Image(systemName: "gamecontroller").font(.largeTitle).foregroundStyle(.tertiary)
        default: Color.clear
        }
    }
}
