//
//  PreviewObjectPoolConsoles.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import XboxKit

extension PreviewObjectPool {
    static var consoles: [Console] {
        [
            .init(id: "F400", name: "Living Room", consoleType: "XboxSeriesX", powerState: .on),
            .init(
                id: "F401",
                name: "Studio",
                consoleType: "XboxSeriesS",
                powerState: .connectedStandby,
                hasWirelessWarning: true
            ),
        ]
    }

    static func homeViewModel(
        state: LoadState = .loaded,
        consoles: [Console] = PreviewObjectPool.consoles
    ) -> HomeViewModel {
        let home = HomeViewModel(
            accountID: profile.xuid,
            service: consoleService(state: state, consoles: consoles),
            cache: libraryCache,
            clock: ContinuousClock()
        )

        Task { await home.refresh() }

        return home
    }

    static func consoleService(state: LoadState, consoles: [Console]) -> PreviewConsoleService {
        .init(reply: .init(state: state), listed: consoles, playing: nowPlaying)
    }
}

private extension PreviewObjectPool {
    static var nowPlaying: ConsoleActivity? {
        cloudGames.first.map { game in
            .init(
                titleID: game.id,
                name: game.name,
                imageURL: game.product?.heroImage,
                kind: .playingNow
            )
        }
    }
}
