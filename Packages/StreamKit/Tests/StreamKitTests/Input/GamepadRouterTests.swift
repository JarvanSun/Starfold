//
//  GamepadRouterTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct GamepadRouterTests {
    @Test
    func setDestinationWhenKeyHeldDuringLastStreamThenDoesNotReplayIt() {
        // Given
        let router = GamepadRouter(routing: .direct)
        let first = GamepadDestinationStub()
        router.setDestination { first.record($0, $1) }
        router.setKeyboard(GamepadState(buttons: [.a]))
        router.setDestination(nil)

        let second = GamepadDestinationStub()

        // When
        router.setDestination { second.record($0, $1) }

        // Then
        #expect(first.latestState(of: 0)?.buttons.contains(.a) == true)
        #expect(second.latestState(of: 0)?.buttons.contains(.a) == false)
    }

    @Test

    func updateWhenTelevisionPlayerOneDisconnectsThenDeliversRemoval() {
        // Given
        let router = GamepadRouter(routing: .television)
        let destination = GamepadDestinationStub()
        router.setDestination { destination.record($0, $1) }
        router.update(slot: 0, state: GamepadState(buttons: [.a]))

        // When
        router.update(slot: 0, state: nil)

        // Then
        #expect(destination.states(of: 0).last! == nil)
    }
}
