//
//  PollingBackoff.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct PollingBackoff: Sendable {
    func delay(after elapsed: Duration) -> Duration {
        switch elapsed {
        case ..<Duration.seconds(2): .milliseconds(100)
        case ..<Duration.seconds(10): .milliseconds(250)
        case ..<Duration.seconds(30): .milliseconds(500)
        default: .seconds(1)
        }
    }
}
