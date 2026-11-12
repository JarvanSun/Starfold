//
//  CloudLibrary.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public struct CloudLibrary {
    var games: [CloudGame]
    var recentGames: [CloudGame]
    var curated: [CatalogClient.List: [CloudGame]]
    var access: CloudAccess

    public init(
        games: [CloudGame],
        recentGames: [CloudGame],
        curated: [CatalogClient.List: [CloudGame]],
        access: CloudAccess
    ) {
        self.games = games
        self.recentGames = recentGames
        self.curated = curated
        self.access = access
    }
}
