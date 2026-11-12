//
//  PacingMode.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum PacingMode: String, CaseIterable, Sendable {
    case standard = "balanced"
    case lowLatency

    public init(storedValue: String?) {
        self = storedValue.flatMap(PacingMode.init(rawValue:)) ?? .standard
    }
}
