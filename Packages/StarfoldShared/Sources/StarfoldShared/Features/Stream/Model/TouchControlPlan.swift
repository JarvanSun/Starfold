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

    public func isRearrangement(of other: TouchControlPlan) -> Bool {
        sticks == other.sticks && controls.count == other.controls.count
            && zip(controls, other.controls).allSatisfy(isSameControl)
    }

    private func isSameControl(_ pair: (TouchControlPlacement, TouchControlPlacement)) -> Bool {
        let (control, other) = pair
        return control.id == other.id && control.input == other.input
            && control.anchor == other.anchor && control.diameter == other.diameter
            && control.symbol == other.symbol
    }
}
