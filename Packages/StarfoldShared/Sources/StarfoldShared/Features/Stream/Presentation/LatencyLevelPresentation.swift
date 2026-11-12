//
//  LatencyLevelPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension LatencyLevel {
    public var color: Color {
        switch self {
        case .low: .online
        case .moderate: .attention
        case .high: .red
        }
    }
}
