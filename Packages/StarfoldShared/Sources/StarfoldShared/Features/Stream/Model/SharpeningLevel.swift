//
//  SharpeningLevel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum SharpeningLevel: Double, CaseIterable {
    case off = 0
    case low = 0.3
    case medium = 0.6
    case high = 1

    init(strength: Double) {
        let nearest = SharpeningLevel.allCases.min {
            abs($0.rawValue - strength) < abs($1.rawValue - strength)
        }
        self = nearest ?? .off
    }
}
