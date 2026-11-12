//
//  TVControllerInputTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct TVControllerInputTests {
    @Test
    func updateWhenMenuPressedAndReleasedThenReleaseComesFromHardware() async {
        // Given
        let queue = DispatchQueue(label: "TVControllerInputTests.menu")
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
        let queue = DispatchQueue(label: "TVControllerInputTests.disconnect")
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
        let queue = DispatchQueue(label: "TVControllerInputTests.interface")
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
}

private extension TVControllerInputTests {
    func makeInput(queue: DispatchQueue, watchedSlot: UInt8) -> (
        TVControllerInput, GamepadDestinationStub
    ) {
        let router = GamepadRouter(routing: .direct)
        let destination = GamepadDestinationStub()
        router.setDestination { slot, state in
            if slot == watchedSlot {
                destination.record(slot, state)
            }
        }
        return (TVControllerInput(queue: queue, router: router), destination)
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
