//
//  ConsoleCardArt.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsoleCardArt: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let console: Console
    let cover: ConsoleCover

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [palette.nightRaised.color, palette.night.color],
                startPoint: .top,
                endPoint: .bottom
            )

            switch cover {
            case .game(let url): gameArtwork(url)
            case .lastFrame(let image): lastFrame(image)
            case .placeholder: modelName
            }
        }
        .clipped()
    }
}

private extension ConsoleCardArt {
    var modelName: some View {
        Text(console.modelName)
            .font(.system(size: dimensions.consoleModelNameSize, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.16))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func gameArtwork(_ url: URL) -> some View {
        AsyncImage(url: url, transaction: .init(animation: .easeOut(duration: 0.4))) {
            phase in
            switch phase.image {
            case let image?: image.resizable().scaledToFill().transition(.opacity)
            case nil: EmptyView()
            }
        }
    }

    func lastFrame(_ image: CGImage) -> some View {
        Image(decorative: image, scale: 1).resizable().scaledToFill()
    }
}
