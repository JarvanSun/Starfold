//
//  InputState.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import QuartzCore

final class InputState: @unchecked Sendable {
    private struct Pulse {
        let button: GamepadButton
        let index: UInt8
        let until: Double
    }

    private let lock = NSLock()
    private let clockOrigin = CACurrentMediaTime()
    private let heartbeatMs: Double

    private var pads: [UInt8: GamepadState] = [:]
    private var latched: [UInt8: GamepadButtons] = [:]
    private var lastSent: [UInt8: (state: GamepadState, at: Double)] = [:]
    private var knownPads: Set<UInt8> = []
    private var pulses: [Pulse] = []
    private var frames: [FrameTimingRecord] = []
    private var onChange: (@Sendable () -> Void)?

    init(heartbeatMs: Double = 50) {
        self.heartbeatMs = heartbeatMs
    }

    func setChangeHandler(_ handler: @escaping @Sendable () -> Void) {
        lock.withLock { onChange = handler }
    }

    func setGamepad(_ index: UInt8, state: GamepadState?) {
        update {
            let hasChanged = pads[index] != state

            switch state {
            case let state?:
                let newlyPressed = state.buttons.subtracting(pads[index]?.buttons ?? [])
                latched[index, default: []].formUnion(newlyPressed)
            case nil:
                latched[index] = nil
            }

            pads[index] = state

            return hasChanged
        }
    }

    func pulse(_ button: GamepadButton, on index: UInt8, duration: TimeInterval) {
        let until = (CACurrentMediaTime() - clockOrigin) * 1000 + duration * 1000
        update {
            pulses.append(.init(button: button, index: index, until: until))

            return true
        }
    }

    private func update(_ body: () -> Bool) {
        let notify = lock.withLock { body() ? onChange : nil }
        notify?()
    }

    func recordFrame(rtpTimestamp: UInt32, at milliseconds: Double) {
        let time = UInt32(truncatingIfNeeded: Int64(milliseconds))
        let record = FrameTimingRecord(
            rtpTimestamp: rtpTimestamp,
            firstPacketArrival: time,
            submittedToDecoder: time,
            decoded: time,
            rendered: time
        )
        lock.withLock {
            if frames.count >= maximumPendingFrames {
                frames.removeFirst()
            }

            frames.append(record)
        }
    }

    private var maximumPendingFrames: Int { 29 }

    @discardableResult
    func drain(now: Double) -> InputSnapshot {
        lock.withLock {
            var snapshot = InputSnapshot()
            let effective = effectivePads()
            let current = Set(effective.keys)
            snapshot.addedPads = current.subtracting(knownPads).sorted()
            snapshot.removedPads = knownPads.subtracting(current).sorted()
            knownPads = current

            for index in snapshot.removedPads {
                lastSent[index] = nil
            }

            snapshot.report.gamepads = gamepadsToSend(effective, now: now)
            snapshot.report.gamepads += snapshot.removedPads.map { ($0, GamepadState()) }
            snapshot.report.frames = frames
            frames.removeAll(keepingCapacity: true)

            return snapshot
        }
    }

    private func effectivePads() -> [UInt8: GamepadState] {
        let pulseClock = (CACurrentMediaTime() - clockOrigin) * 1000
        pulses.removeAll { $0.until < pulseClock }

        var effective = pads

        for pulse in pulses {
            effective[pulse.index, default: GamepadState()].buttons.insert(pulse.button)
        }

        for (index, buttons) in latched where effective[index] != nil {
            effective[index]?.buttons.formUnion(buttons)
        }

        latched.removeAll(keepingCapacity: true)

        return effective
    }

    private func gamepadsToSend(_ effective: [UInt8: GamepadState], now: Double) -> [(
        index: UInt8, state: GamepadState
    )] {
        var gamepads: [(index: UInt8, state: GamepadState)] = []

        for (index, state) in effective.sorted(by: { $0.key < $1.key }) {
            if let last = lastSent[index], last.state == state, now - last.at < heartbeatMs {
                continue
            }

            gamepads.append((index, state))

            lastSent[index] = (state, now)
        }

        return gamepads
    }
}
