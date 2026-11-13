//
//  TouchControlPlan.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchControlPlan: Hashable, Sendable {
    public let controls: [TouchControlPlacement]
    public let opacity: Double
    public let sticks: TouchSticks

    public init(controls: [TouchControlPlacement], opacity: Double, sticks: TouchSticks) {
        self.controls = controls
        self.opacity = opacity
        self.sticks = sticks
    }
}
