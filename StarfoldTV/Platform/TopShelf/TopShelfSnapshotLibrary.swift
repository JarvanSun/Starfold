//
//  TopShelfSnapshotLibrary.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StarfoldShared
import TopShelfKit
import XboxKit

extension TopShelfSnapshot {
    init?(appViewModel: AppViewModel) {
        switch (
            appViewModel.sessionState, appViewModel.homeViewModel, appViewModel.libraryViewModel
        ) {
        case (.restoring, _, _): return nil
        case (.signedOut, _, _): self.init()
        case (.signedIn, let home?, let library?):
            self.init(
                recentGames: library.recentGames,
                consoles: home.consoles,
                activity: home.activity(for:)
            )
        case (.signedIn, _, _): return nil
        }
    }

    init(recentGames: [CloudGame], consoles: [Console], activity: (Console) -> ConsoleActivity?) {
        self.init()

        gamesTitle = String(localized: "topShelf.recentGames.title")
        games = recentGames.prefix(rowItemLimit).map(TopShelfItem.init(game:))
        consolesTitle = String(localized: "topShelf.consoles.title")
        self.consoles = consoles.prefix(rowItemLimit).map { console in
            TopShelfItem(console: console, activity: activity(console))
        }
    }
}

private extension TopShelfItem {
    init(game: CloudGame) {
        self.init(id: game.id, title: game.name, imageURL: game.titledWideArtwork)
    }

    init(console: Console, activity: ConsoleActivity?) {
        self.init(id: console.id, title: console.name, imageURL: activity?.imageURL)
    }
}

private extension CloudGame {
    var titledWideArtwork: URL? {
        product?.titledHeroImage ?? product?.heroImage ?? product?.tileImage
    }
}
