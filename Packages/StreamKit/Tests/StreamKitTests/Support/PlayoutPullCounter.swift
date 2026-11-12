//
//  PlayoutPullCounter.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Synchronization

final class PlayoutPullCounter: Sendable {
    let pulls = Atomic<Int>(0)
    let frames = Atomic<Int>(0)
    let largestPull = Atomic<Int>(0)
}
