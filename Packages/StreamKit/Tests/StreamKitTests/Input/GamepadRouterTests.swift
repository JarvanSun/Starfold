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

    func updateWhenGatedPlayerOneDisconnectsThenDeliversRemoval() {
        // Given
        let router = GamepadRouter(routing: .gated)
        let destination = GamepadDestinationStub()
        router.setDestination { destination.record($0, $1) }
        router.update(slot: 0, state: GamepadState(buttons: [.a]))

        // When
        router.update(slot: 0, state: nil)

        // Then
        #expect(destination.states(of: 0).last! == nil)
    }

    @Test(arguments: [ControllerRouting.direct, .gated])
    func updateTouchWhenPadInSlotZeroThenMergesTouchAsVirtualIntoPlayerOne(
        routing: ControllerRouting
    ) {
        // Given
        let (router, destination) = makeRouter(routing: routing)
        router.update(slot: 0, state: GamepadState(buttons: [.a]))

        // When
        router.updateTouch(GamepadState(buttons: [.b]))

        // Then
        let playerOne = destination.latestState(of: 0)
        #expect(playerOne?.buttons == [.a, .b])
        #expect(playerOne?.physicality == GamepadPhysicality(physical: 0x1000, virtual: 0x2000))
    }

    @Test
    func updateTouchWhenOtherPlayersConnectedThenOnlyEverReachesSlotZero() {
        // Given
        let (router, destination) = makeRouter(routing: .direct)
        router.update(slot: 1, state: GamepadState(buttons: [.x]))
        destination.clear()

        // When
        router.updateTouch(GamepadState(buttons: [.y]))

        // Then
        #expect(destination.states(of: 1).isEmpty)
        #expect(destination.latestState(of: 0)?.buttons == [.y])
        #expect(destination.latestState(of: 0)?.physicality.physical == 0)
    }

    @Test
    func setKeyboardWhenGatedThenMergesKeysIntoPlayerOne() {
        // Given
        let (router, destination) = makeRouter(routing: .gated)
        router.update(slot: 0, state: GamepadState(buttons: [.a]))

        // When
        router.setKeyboard(GamepadState(buttons: [.menu]))

        // Then
        #expect(destination.latestState(of: 0)?.buttons == [.a, .menu])
    }

    @Test
    func setKeyboardWhenGatedWithNothingElseThenRemovesPlayerOneOnRelease() {
        // Given
        let (router, destination) = makeRouter(routing: .gated)
        router.setKeyboard(GamepadState(buttons: [.a]))

        // When
        router.setKeyboard(GamepadState())

        // Then
        #expect(destination.states(of: 0).suffix(2) == [GamepadState(buttons: [.a]), nil])
    }

    @Test
    func updateWhenInputSwitchesBackAndForthThenReportsEachFlipOnce() {
        // Given
        let (router, _) = makeRouter(routing: .gated)
        let handler = ActiveInputHandlerStub()
        router.setActiveInputHandler { handler.record($0) }

        // When
        for _ in 0..<3 {
            router.updateTouch(GamepadState(buttons: [.a]))
        }

        for _ in 0..<3 {
            router.update(slot: 0, state: GamepadState(leftStick: SIMD2(0, 1)))
        }

        router.setKeyboard(GamepadState(buttons: [.b]))
        router.updateTouch(GamepadState(buttons: [.x]))
        router.updateTouch(GamepadState())

        // Then
        #expect(handler.recordedChanges == [.controller, .touch])
    }

    @Test
    func clearPendingInputWhenTouchAndPadThenClearsSlotZeroOnceAndResetsBoth() {
        // Given
        let (router, destination) = makeRouter(routing: .gated)
        router.update(slot: 0, state: GamepadState(buttons: [.a]))
        router.updateTouch(GamepadState(buttons: [.b]))
        destination.clear()

        // When
        router.clearPendingInput(from: [.slot(0), .touch])
        router.update(slot: 0, state: GamepadState())

        // Then
        #expect(destination.states(of: 0) == [nil, GamepadState()])
    }
}

private extension GamepadRouterTests {
    func makeRouter(routing: ControllerRouting) -> (GamepadRouter, GamepadDestinationStub) {
        let router = GamepadRouter(routing: routing)
        let destination = GamepadDestinationStub()
        router.setDestination { destination.record($0, $1) }
        return (router, destination)
    }
}
