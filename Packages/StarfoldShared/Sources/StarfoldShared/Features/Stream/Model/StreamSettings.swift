//
//  StreamSettings.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import XboxKit

struct StreamSettings: Equatable {
    let choice: QualityChoice
    let maxBitrateMbps: Int
    let requestsConsole1440p: Bool

    var maxBitrateKbps: Int? {
        let kilobitsPerMegabit = 1000

        return maxBitrateMbps > 0 ? maxBitrateMbps * kilobitsPerMegabit : nil
    }

    init(target: StreamTarget, preferences: Preferences) {
        switch target {
        case .console:
            requestsConsole1440p = preferences.requestsConsole1440p
            choice = requestsConsole1440p ? .fixed(.highest) : preferences.consoleQuality
        case .cloud:
            requestsConsole1440p = false
            choice = preferences.cloudQuality
        }
        maxBitrateMbps = preferences.maxBitrateMbps
    }
}
