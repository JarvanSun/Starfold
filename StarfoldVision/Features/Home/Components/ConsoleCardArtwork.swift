//
//  ConsoleCardArtwork.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ConsoleCardArtwork: View {
    @Environment(\.dimensions) private var dimensions

    let console: Console
    let cover: ConsoleCover

    var body: some View {
        Rectangle()
            .fill(.thinMaterial)
            .overlay { picture }
            .frame(height: dimensions.consoleCardArtworkHeight)
            .clipped()
    }

    @ViewBuilder
    private var picture: some View {
        switch cover {
        case .game(let url): gameCover(url)
        case .lastFrame(let image): Image(decorative: image, scale: 1).resizable().scaledToFill()
        case .placeholder: modelName
        }
    }

    private func gameCover(_ url: URL) -> some View {
        AsyncImage(url: url, transaction: .init(animation: fadeIn)) { phase in
            switch phase.image {
            case let image?: image.resizable().scaledToFill().transition(.opacity)
            case nil: EmptyView()
            }
        }
    }

    private var fadeIn: Animation {
        .easeOut(duration: 0.4)
    }

    private var modelName: some View {
        Text(console.modelName)
            .font(
                .system(size: dimensions.consoleModelNameFontSize, weight: .bold, design: .rounded)
            )
            .foregroundStyle(.quaternary)
    }
}

#if DEBUG
#Preview("Console artwork") {
    ConsoleCardArtwork(console: PreviewObjectPool.consoles[0], cover: .placeholder)
        .frame(width: 400)
        .padding()
}
#endif
