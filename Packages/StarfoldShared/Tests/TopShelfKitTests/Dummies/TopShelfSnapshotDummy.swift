//
//  TopShelfSnapshotDummy.swift
//  TopShelfKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import TopShelfKit

extension TopShelfSnapshot {
    static var dummyContinuePlaying: TopShelfSnapshot {
        .init(gamesTitle: "Continue Playing", games: [.init(id: "A", title: "A", imageURL: nil)])
    }
}
