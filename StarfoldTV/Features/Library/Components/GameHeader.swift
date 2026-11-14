//
//  GameHeader.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct GameHeader: View {
    @Environment(\.dimensions) private var dimensions

    let gameDetailViewModel: GameDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
            Text(gameDetailViewModel.name).font(.largeTitle.bold())

            if let publisher = gameDetailViewModel.publisher {
                Text(publisher).foregroundStyle(.secondary)
            }

            HStack(spacing: dimensions.spaceXXLarge) {
                Button("game.play") { gameDetailViewModel.play() }.buttonStyle(.borderedProminent)

                Button {
                    gameDetailViewModel.toggleFavorite()
                } label: {
                    Text(gameDetailViewModel.favoriteAction.title)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    GameHeader(gameDetailViewModel: PreviewObjectPool.gameDetailViewModel)
}
#endif
