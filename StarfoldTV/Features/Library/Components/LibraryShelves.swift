//
//  LibraryShelves.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryShelves: View {
    let libraryViewModel: LibraryViewModel

    var body: some View {
        if libraryViewModel.isLimitedToFreeToPlay {
            Text("library.freeToPlay.notice").foregroundStyle(.secondary)
        }

        ForEach(libraryViewModel.shelves) { shelf in
            GameShelf(title: shelf.title, games: libraryViewModel.games(on: shelf))
        }

        Text("library.allGames.title").font(.title2.bold())

        GameGrid(games: libraryViewModel.games)
    }
}

#if DEBUG
#Preview(arguments: [CloudAccess.gamePass, .freeToPlay]) { access in
    ScrollView {
        VStack(alignment: .leading) {
            LibraryShelves(libraryViewModel: PreviewObjectPool.libraryViewModel(access: access))
        }
    }
}
#endif
