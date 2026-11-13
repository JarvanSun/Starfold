//
//  TouchControlPlan.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchControlPlan: Hashable, Sendable {
    public let controls: [TouchControlPlacement]
    public let opacity: Double

    public init(controls: [TouchControlPlacement], opacity: Double) {
        self.controls = controls
        self.opacity = opacity
    }
}
