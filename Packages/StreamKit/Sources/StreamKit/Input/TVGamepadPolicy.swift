//
//  TVGamepadPolicy.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

struct TVGamepadPolicy {
    struct Output {
        var states: [UInt8: GamepadState] = [:]
        var shouldClearPendingInput = false
        var removedSlots: [UInt8] = []
    }

    private(set) var isPlaying = false

    private var physical: [UInt8: GamepadState] = [:]
    private var blocked: [UInt8: GamepadState] = [:]

    @discardableResult
    mutating func setPlaying(_ isPlaying: Bool) -> Output {
        guard self.isPlaying != isPlaying else { return Output() }

        self.isPlaying = isPlaying
        blocked = physical

        let neutral = Dictionary(uniqueKeysWithValues: physical.keys.map { ($0, GamepadState()) })
        return Output(states: neutral, shouldClearPendingInput: true)
    }

    @discardableResult
    mutating func update(slot: UInt8, state: GamepadState?) -> Output {
        guard let state else {
            physical[slot] = nil
            blocked[slot] = nil

            return Output(removedSlots: [slot])
        }

        physical[slot] = state

        guard isPlaying else { return Output(states: [slot: GamepadState()]) }

        return Output(states: [slot: quarantine(state, slot: slot)])
    }
}

private extension TVGamepadPolicy {
    var releaseThreshold: Float { 0.1 }

    mutating func quarantine(_ state: GamepadState, slot: UInt8) -> GamepadState {
        let barrier = releasedBarrier(blocked[slot] ?? GamepadState(), current: state)
        blocked[slot] = barrier

        var clean = state
        clean.buttons.subtract(barrier.buttons)

        if barrier.leftStick != .zero {
            clean.leftStick = .zero
        }

        if barrier.rightStick != .zero {
            clean.rightStick = .zero
        }

        if barrier.leftTrigger > 0 {
            clean.leftTrigger = 0
        }

        if barrier.rightTrigger > 0 {
            clean.rightTrigger = 0
        }

        return clean
    }

    func releasedBarrier(_ barrier: GamepadState, current state: GamepadState) -> GamepadState {
        var barrier = barrier
        barrier.buttons.formIntersection(state.buttons)

        if isReleased(state.leftStick) {
            barrier.leftStick = .zero
        }

        if isReleased(state.rightStick) {
            barrier.rightStick = .zero
        }

        if state.leftTrigger < releaseThreshold {
            barrier.leftTrigger = 0
        }

        if state.rightTrigger < releaseThreshold {
            barrier.rightTrigger = 0
        }

        return barrier
    }

    func isReleased(_ stick: SIMD2<Float>) -> Bool {
        abs(stick.x) < releaseThreshold && abs(stick.y) < releaseThreshold
    }
}
