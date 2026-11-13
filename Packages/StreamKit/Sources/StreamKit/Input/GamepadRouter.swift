//
//  GamepadRouter.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation

public final class GamepadRouter: @unchecked Sendable {
    public typealias Destination = @Sendable (_ slot: UInt8, _ state: GamepadState?) -> Void

    private let routing: ControllerRouting
    private let lock = NSLock()

    private var destination: Destination?
    private var pads: [UInt8: GamepadState] = [:]
    private var keyboard = GamepadState()

    init(routing: ControllerRouting) {
        self.routing = routing
    }

    public func setDestination(_ destination: Destination?) {
        lock.withLock {
            self.destination = destination
            keyboard = GamepadState()

            guard let destination else { return }

            if pads[0] == nil {
                destination(0, keyboard)
            }

            for slot in pads.keys.sorted() {
                destination(slot, state(for: slot))
            }
        }
    }

    public func setKeyboard(_ state: GamepadState) {
        lock.withLock {
            keyboard = state

            destination?(0, self.state(for: 0))
        }
    }

    func update(slot: UInt8, state: GamepadState?) {
        lock.withLock {
            pads[slot] = state

            destination?(slot, self.state(for: slot))
        }
    }

    private func state(for slot: UInt8) -> GamepadState? {
        switch (slot, routing) {
        case (0, .direct): pads[0].map { $0.merged(with: keyboard) } ?? keyboard
        default: pads[slot]
        }
    }

    func clearPendingPhysicalInput(slots: [UInt8]) {
        lock.withLock {
            if slots.contains(0) {
                keyboard = GamepadState()
            }

            for slot in slots.sorted() {
                destination?(slot, nil)

                pads[slot] = GamepadState()
            }
        }
    }
}
