//
//  TouchControlPlacement.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

public struct TouchControlPlacement: Identifiable, Hashable, Sendable {
    public let id: String
    public let input: TouchInput
    public let anchor: TouchAnchor
    public let offset: CGPoint
    public let diameter: CGFloat
    public let symbol: String

    public init(
        id: String,
        input: TouchInput,
        anchor: TouchAnchor,
        offset: CGPoint,
        diameter: CGFloat,
        symbol: String
    ) {
        self.id = id
        self.input = input
        self.anchor = anchor
        self.offset = offset
        self.diameter = diameter
        self.symbol = symbol
    }
}
