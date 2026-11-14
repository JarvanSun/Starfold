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

    private var hapticEngines: [GCHapticsLocality: CHHapticEngine] = [:]
    private var patternPlayers: [GCHapticsLocality: CHHapticPatternPlayer] = [:]

    init?(controller: GCController) {
        guard let haptics = controller.haptics else { return nil }

        startLocalizedEngines(haptics)

        if hapticEngines.isEmpty, let engine = haptics.createEngine(withLocality: .default) {
            try? engine.start()
            hapticEngines[.default] = engine
        }

        guard !hapticEngines.isEmpty else { return nil }
    }

    private func startLocalizedEngines(_ haptics: GCDeviceHaptics) {
        let localities: [GCHapticsLocality] = [
            .leftHandle, .rightHandle, .leftTrigger, .rightTrigger,
        ]

        for locality in localities where haptics.supportedLocalities.contains(locality) {
            if let engine = haptics.createEngine(withLocality: locality) {
                engine.playsHapticsOnly = true
                try? engine.start()
                hapticEngines[locality] = engine
            }
        }
    }

    private func start(_ pattern: CHHapticPattern, on engine: CHHapticEngine)
        -> CHHapticPatternPlayer?
    {
        do {
            return try startPlayer(pattern, on: engine)
        } catch {
            return restartEngineAndStartPlayer(pattern, on: engine)
        }
    }

    private func startPlayer(_ pattern: CHHapticPattern, on engine: CHHapticEngine) throws
        -> CHHapticPatternPlayer
    {
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
        return player
    }

    private func restartEngineAndStartPlayer(
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

    init?(device: CHHapticDeviceCapability) {
        guard device.supportsHaptics, let engine = try? CHHapticEngine() else { return nil }

        engine.playsHapticsOnly = true
        try? engine.start()
        hapticEngines[.default] = engine
    }

    func play(_ effect: VibrationEffect) {
        for (locality, engine) in hapticEngines {
            try? patternPlayers[locality]?.stop(atTime: CHHapticTimeImmediate)

            patternPlayers[locality] = pattern(of: effect, at: locality).flatMap {
                start($0, on: engine)
            }
        }
    }

    private func pattern(of effect: VibrationEffect, at locality: GCHapticsLocality)
        -> CHHapticPattern?
    {
        let intensity = effect.intensity(at: locality)
        let duration = effect.duration / .seconds(1)
        let minimumIntensity: Float = 0.01
        guard intensity > minimumIntensity, duration > 0 else { return nil }

        let period = duration + effect.delay / .seconds(1)
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

    private func parameters(intensity: Float, at locality: GCHapticsLocality)
        -> [CHHapticEventParameter]
    {
        [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness(at: locality)),
        ]
    }

    private func sharpness(at locality: GCHapticsLocality) -> Float {
        switch locality {
        case .rightHandle: 0.8
        default: 0.3
        }
    }

    func stop() {
        for player in patternPlayers.values {
            try? player.stop(atTime: CHHapticTimeImmediate)
        }

        patternPlayers.removeAll()
    }
}

private extension VibrationEffect {
    func intensity(at locality: GCHapticsLocality) -> Float {
        switch locality {
        case .leftHandle: leftMotor
        case .rightHandle: rightMotor
        case .leftTrigger: leftTrigger
        case .rightTrigger: rightTrigger
        case .default: max(leftMotor, rightMotor)
        default: 0
        }
    }
}
