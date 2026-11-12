//
//  TopShelfLinkDummy.swift
//  TopShelfKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import TopShelfKit

extension TopShelfLink {
    nonisolated static var dummyPlayGame: TopShelfLink {
        .game(id: "FORTNITE", name: "Fortnite: Battle & Build", shouldPlay: true)
    }

    nonisolated static var dummyShowGameWithAccentedName: TopShelfLink {
        .game(id: "REMATCH", name: "Pokémon Café Rémix", shouldPlay: false)
    }

    nonisolated static var dummyConsole: TopShelfLink {
        .console(id: "F4001ABCDEF", name: "Living room Xbox")
    }
}
