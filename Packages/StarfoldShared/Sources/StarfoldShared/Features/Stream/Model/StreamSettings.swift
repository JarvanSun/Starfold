//
//  StreamSettings.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

struct StreamSettings: Equatable {
    let choice: QualityChoice
    let maxBitrateMbps: Int

    var maxBitrateKbps: Int? {
        let kilobitsPerMegabit = 1000

        return switch maxBitrateMbps > 0 {
        case true: maxBitrateMbps * kilobitsPerMegabit
        case false: nil
        }
    }

    init(target: StreamTarget, preferences: Preferences) {
        choice =
            switch target {
            case .console: preferences.consoleQuality
            case .cloud: preferences.cloudQuality
            }
        maxBitrateMbps = preferences.maxBitrateMbps
    }
}
