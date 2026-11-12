//
//  CloudLibraryDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

@testable import StarfoldShared

extension CloudLibrary {
    static var dummyEmpty: CloudLibrary {
        .init(games: [], recentGames: [], curated: [:], access: .unavailable)
    }

    static var dummyGamePass: CloudLibrary {
        .init(
            games: [.dummyZetaQuest, .dummyAlphaRacer],
            recentGames: [.dummyAlphaRacer],
            curated: [.recentlyAdded: [.dummyZetaQuest]],
            access: .gamePass
        )
    }
}
