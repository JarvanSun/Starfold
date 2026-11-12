//
//  LibraryShelves.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibraryShelves: View {
    let library: LibraryViewModel

    var body: some View {
        if library.isLimitedToFreeToPlay {
            Text("library.freeToPlay.notice").foregroundStyle(.secondary)
        }

        ForEach(library.shelves) { shelf in
            GameShelf(title: shelf.title, games: library.games(on: shelf))
        }

        Text("library.allGames.title").font(.title2.bold())

        GameGrid(games: library.games)
    }
}

#if DEBUG
#Preview(arguments: [CloudAccess.gamePass, .freeToPlay]) { access in
    ScrollView {
        VStack(alignment: .leading) {
            LibraryShelves(library: PreviewObjectPool.libraryViewModel(access: access))
        }
    }
}
#endif
