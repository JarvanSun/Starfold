//
//  GatedControllerInputTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct GatedControllerInputTests {
    @Test
    func updateWhenMenuPressedAndReleasedThenReleaseComesFromHardware() async {
        // Given
        let queue = DispatchQueue(label: "GatedControllerInputTests.menu")
        let (input, destination) = makeInput(queue: queue, watchedSlot: 0)
        destination.clear()

        input.setPlaying(true)

        // When
        await run(on: queue) { input.update(slot: 0, state: GamepadState(buttons: [.menu])) }

        let afterPress = destination.recordedStates

        await run(on: queue) { input.update(slot: 0, state: GamepadState()) }

        // Then
        #expect(afterPress == [GamepadState(buttons: [.menu])])
        #expect(destination.recordedStates == [GamepadState(buttons: [.menu]), GamepadState()])
    }

    @Test

    func updateWhenPlayerDisconnectsThenRemovesSlotInsteadOfLeavingNeutralPad() async {
        // Given
        let queue = DispatchQueue(label: "GatedControllerInputTests.disconnect")
        let (input, destination) = makeInput(queue: queue, watchedSlot: 1)
        input.setPlaying(true)

        // When
        await run(on: queue) {
            input.update(slot: 1, state: GamepadState(buttons: [.a]))
            input.update(slot: 1, state: nil)
        }

        // Then
        #expect(destination.recordedStates == [GamepadState(buttons: [.a]), nil])
    }

    @Test

    func setPlayingWhenStoppedThenClearsPendingTapsBeforeSendingNeutral() async {
        // Given
        let queue = DispatchQueue(label: "GatedControllerInputTests.interface")
        let (input, destination) = makeInput(queue: queue, watchedSlot: 0)
        input.setPlaying(true)
        await run(on: queue) {
            input.update(slot: 0, state: GamepadState(buttons: [.a]))

            destination.clear()
        }

        // When
        input.setPlaying(false)

        await run(on: queue) {}

        // Then
        #expect(destination.recordedStates.count == 2)
        #expect(destination.recordedStates.first! == nil)
        #expect(destination.recordedStates.last! == GamepadState())
    }

    @Test
    func setPlayingWhenStoppedWithTouchHeldThenClearsPlayerOneBeforeSendingNeutral() async {
        // Given
        let queue = DispatchQueue(label: "GatedControllerInputTests.touchInterface")
        let (input, destination) = makeInput(queue: queue, watchedSlot: 0)
        input.setPlaying(true)
        await run(on: queue) {
            input.updateTouch(GamepadState(buttons: [.a]))

            destination.clear()
        }

        // When
        input.setPlaying(false)

        await run(on: queue) {}

        // Then
        #expect(destination.recordedStates == [nil, GamepadState()])
    }

    @Test
    func updateTouchWhenHeldThroughInterruptionThenCountsOnlyAfterRelease() async {
        // Given
        let queue = DispatchQueue(label: "GatedControllerInputTests.touchHeld")
        let (input, destination) = makeInput(queue: queue, watchedSlot: 0)
        input.setPlaying(true)
        await run(on: queue) { input.updateTouch(GamepadState(buttons: [.a])) }
        input.setPlaying(false)
        input.setPlaying(true)
        await run(on: queue) { destination.clear() }

        // When
        await run(on: queue) {
            input.updateTouch(GamepadState(buttons: [.a]))
            input.updateTouch(GamepadState())
            input.updateTouch(GamepadState(buttons: [.a]))
        }

        // Then
        #expect(destination.recordedStates.last??.buttons == [.a])
        #expect(destination.recordedStates.dropLast().allSatisfy { $0 == GamepadState() })
    }
}

private extension GatedControllerInputTests {
    func makeInput(queue: DispatchQueue, watchedSlot: UInt8) -> (
        GatedControllerInput, GamepadDestinationStub
    ) {
        let router = GamepadRouter(controllerRouting: .direct)
        let destination = GamepadDestinationStub()
        router.setDestination { slot, state in
            if slot == watchedSlot {
                destination.record(slot, state)
            }
        }
        return (GatedControllerInput(inputQueue: queue, gamepadRouter: router), destination)
    }

    func run(on queue: DispatchQueue, _ body: @escaping @Sendable () -> Void) async {
        await withCheckedContinuation { continuation in
            queue.async {
                body()

                continuation.resume()
            }
        }
    }
}
