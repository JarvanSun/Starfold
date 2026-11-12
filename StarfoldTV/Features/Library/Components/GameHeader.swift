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

    let detail: GameDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
            Text(detail.name).font(.largeTitle.bold())

            switch detail.publisher {
            case let publisher?: Text(publisher).foregroundStyle(.secondary)
            case nil: EmptyView()
            }

            HStack(spacing: dimensions.spaceXXLarge) {
                Button("game.play") { detail.play() }.buttonStyle(.borderedProminent)

                Button {
                    detail.toggleFavorite()
                } label: {
                    Text(detail.favoriteAction.title)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    GameHeader(detail: PreviewObjectPool.gameDetailViewModel)
}
#endif
