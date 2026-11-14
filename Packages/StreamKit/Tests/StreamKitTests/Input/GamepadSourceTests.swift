//
//  GamepadSourceTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

struct GamepadSourceTests {
    @Test
    func slotWhenTouchThenIsPlayerOne() {
        #expect(GamepadSource.touch.slot == 0)
    }

    @Test
    func sortedThenPutsSlotsInOrderBeforeTouch() {
        #expect(
            [.touch, .slot(2), .slot(0)].sorted() == [GamepadSource.slot(0), .slot(2), .touch]
        )
    }
}
