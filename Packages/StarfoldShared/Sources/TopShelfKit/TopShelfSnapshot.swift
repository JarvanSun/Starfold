//
//  TopShelfSnapshot.swift
//  TopShelfKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation

public nonisolated struct TopShelfSnapshot: Codable, Equatable, Sendable {
    public var gamesTitle: String
    public var games: [TopShelfItem]
    public var consolesTitle: String
    public var consoles: [TopShelfItem]

    public var isEmpty: Bool {
        games.isEmpty && consoles.isEmpty
    }

    public var rowItemLimit: Int {
        10
    }

    public init(
        gamesTitle: String = "",
        games: [TopShelfItem] = [],
        consolesTitle: String = "",
        consoles: [TopShelfItem] = []
    ) {
        self.gamesTitle = gamesTitle
        self.games = games
        self.consolesTitle = consolesTitle
        self.consoles = consoles
    }
}
