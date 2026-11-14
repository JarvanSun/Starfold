//
//  TouchControlAdjustment.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

struct TouchControlAdjustment: Codable, Hashable, Sendable {
    var offset = CGPoint.zero
    var scale: Double = 1
}
