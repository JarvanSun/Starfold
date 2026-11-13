//
//  TouchMetricsDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

@testable import StarfoldShared

extension TouchMetrics {
    static var dummy: TouchMetrics {
        .init(stickDiameter: 130, buttonDiameter: 56, smallButtonDiameter: 36, edgeMargin: 16)
    }
}
