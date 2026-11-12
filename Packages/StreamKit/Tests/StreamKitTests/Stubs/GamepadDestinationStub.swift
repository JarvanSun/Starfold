//
//  GamepadDestinationStub.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

@testable import StreamKit

final class GamepadDestinationStub: @unchecked Sendable {
    private let lock = NSLock()

    private var deliveries: [(slot: UInt8, state: GamepadState?)] = []

    var recordedStates: [GamepadState?] {
        lock.withLock { deliveries.map(\.state) }
    }

    func record(_ slot: UInt8, _ state: GamepadState?) {
        lock.withLock { deliveries.append((slot, state)) }
    }

    func latestState(of slot: UInt8) -> GamepadState? {
        lock.withLock { deliveries.last { $0.slot == slot }?.state }
    }

    func states(of slot: UInt8) -> [GamepadState?] {
        lock.withLock { deliveries.filter { $0.slot == slot }.map(\.state) }
    }

    func clear() {
        lock.withLock { deliveries.removeAll() }
    }
}
