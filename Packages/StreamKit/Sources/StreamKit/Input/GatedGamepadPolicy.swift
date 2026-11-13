//
//  GatedGamepadPolicy.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

struct GatedGamepadPolicy {
    struct Output {
        var states: [GamepadSource: GamepadState] = [:]
        var shouldClearPendingInput = false
        var removed: [GamepadSource] = []
    }

    private(set) var isPlaying = false

    private var held: [GamepadSource: GamepadState] = [:]
    private var blocked: [GamepadSource: GamepadState] = [:]

    private var releaseThreshold: Float { 0.1 }

    @discardableResult
    mutating func setPlaying(_ isPlaying: Bool) -> Output {
        guard self.isPlaying != isPlaying else { return Output() }

        self.isPlaying = isPlaying
        blocked = held

        let neutral = Dictionary(uniqueKeysWithValues: held.keys.map { ($0, GamepadState()) })
        return Output(states: neutral, shouldClearPendingInput: true)
    }

    @discardableResult
    mutating func update(_ source: GamepadSource, state: GamepadState?) -> Output {
        guard let state else {
            held[source] = nil
            blocked[source] = nil

            return Output(removed: [source])
        }

        held[source] = state

        guard isPlaying else { return Output(states: [source: GamepadState()]) }

        return Output(states: [source: quarantine(state, from: source)])
    }

    private mutating func quarantine(_ state: GamepadState, from source: GamepadSource)
        -> GamepadState
    {
        let barrier = releasedBarrier(blocked[source] ?? GamepadState(), current: state)
        blocked[source] = barrier

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

    private func releasedBarrier(_ barrier: GamepadState, current state: GamepadState)
        -> GamepadState
    {
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

    private func isReleased(_ stick: SIMD2<Float>) -> Bool {
        abs(stick.x) < releaseThreshold && abs(stick.y) < releaseThreshold
    }
}
