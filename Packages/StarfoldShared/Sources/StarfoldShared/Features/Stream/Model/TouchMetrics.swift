//
//  TouchMetrics.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

public struct TouchMetrics: Hashable, Sendable {
    let stickDiameter: CGFloat
    let buttonDiameter: CGFloat
    let smallButtonDiameter: CGFloat
    let edgeMargin: CGFloat

    public init(
        stickDiameter: CGFloat,
        buttonDiameter: CGFloat,
        smallButtonDiameter: CGFloat,
        edgeMargin: CGFloat
    ) {
        self.stickDiameter = stickDiameter
        self.buttonDiameter = buttonDiameter
        self.smallButtonDiameter = smallButtonDiameter
        self.edgeMargin = edgeMargin
    }
}
