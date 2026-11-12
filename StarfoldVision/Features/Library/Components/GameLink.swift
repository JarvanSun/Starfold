//
//  GameLink.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct GameLink: View {
    let game: CloudGame
    let onPlay: () -> Void

    var body: some View {
        NavigationLink(value: game) {
            GameTile(game: game)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("library.game.play", systemImage: "play.fill", action: onPlay)
        }
    }
}

#if DEBUG
#Preview("Game link") {
    NavigationStack {
        GameLink(game: PreviewObjectPool.cloudGames[0]) {}
            .padding()
    }
}
#endif
