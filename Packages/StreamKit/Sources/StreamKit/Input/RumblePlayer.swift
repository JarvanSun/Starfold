//
//  RumblePlayer.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreHaptics
import GameController
import os

final class RumblePlayer {
    private let log = Logger(category: .controllers)

    private var engines: [GCHapticsLocality: CHHapticEngine] = [:]
    private var players: [GCHapticsLocality: CHHapticPatternPlayer] = [:]

    init?(controller: GCController) {
        guard let haptics = controller.haptics else { return nil }

        startLocalizedEngines(haptics)

        if engines.isEmpty, let engine = haptics.createEngine(withLocality: .default) {
            try? engine.start()
            engines[.default] = engine
        }

        guard !engines.isEmpty else { return nil }
    }

    func play(_ effect: VibrationEffect) {
        for (locality, engine) in engines {
            try? players[locality]?.stop(atTime: CHHapticTimeImmediate)

            players[locality] = pattern(of: effect, at: locality).flatMap { start($0, on: engine) }
        }
    }

    func stop() {
        for player in players.values {
            try? player.stop(atTime: CHHapticTimeImmediate)
        }

        players.removeAll()
    }
}

private extension RumblePlayer {
    var minimumIntensity: Float { 0.01 }

    var localities: [GCHapticsLocality] {
        [.leftHandle, .rightHandle, .leftTrigger, .rightTrigger]
    }

    func startLocalizedEngines(_ haptics: GCDeviceHaptics) {
        for locality in localities where haptics.supportedLocalities.contains(locality) {
            if let engine = haptics.createEngine(withLocality: locality) {
                engine.playsHapticsOnly = true
                try? engine.start()
                engines[locality] = engine
            }
        }
    }

    func pattern(of effect: VibrationEffect, at locality: GCHapticsLocality) -> CHHapticPattern? {
        let intensity = intensity(of: effect, at: locality)
        let duration = seconds(effect.duration)
        guard intensity > minimumIntensity, duration > 0 else { return nil }

        let period = duration + seconds(effect.delay)
        let events = (0...effect.repeatCount).map { repetition in
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: parameters(intensity: intensity, at: locality),
                relativeTime: Double(repetition) * period,
                duration: duration
            )
        }
        return try? CHHapticPattern(events: events, parameters: [])
    }

    func intensity(of effect: VibrationEffect, at locality: GCHapticsLocality) -> Float {
        switch locality {
        case .leftHandle: effect.leftMotor
        case .rightHandle: effect.rightMotor
        case .leftTrigger: effect.leftTrigger
        case .rightTrigger: effect.rightTrigger
        case .default: max(effect.leftMotor, effect.rightMotor)
        default: 0
        }
    }

    func parameters(intensity: Float, at locality: GCHapticsLocality) -> [CHHapticEventParameter] {
        [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness(at: locality)),
        ]
    }

    func sharpness(at locality: GCHapticsLocality) -> Float {
        switch locality {
        case .rightHandle: 0.8
        default: 0.3
        }
    }

    func start(_ pattern: CHHapticPattern, on engine: CHHapticEngine) -> CHHapticPatternPlayer? {
        do {
            return try startPlayer(pattern, on: engine)
        } catch {
            return restartEngineAndStartPlayer(pattern, on: engine)
        }
    }

    func restartEngineAndStartPlayer(
        _ pattern: CHHapticPattern,
        on engine: CHHapticEngine
    ) -> CHHapticPatternPlayer? {
        do {
            try engine.start()
            return try startPlayer(pattern, on: engine)
        } catch {
            log.error("Rumble failed: \(error.localizedDescription, privacy: .public)")

            return nil
        }
    }

    func startPlayer(_ pattern: CHHapticPattern, on engine: CHHapticEngine) throws
        -> CHHapticPatternPlayer
    {
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
        return player
    }

    func seconds(_ duration: Duration) -> Double {
        duration / .seconds(1)
    }
}
