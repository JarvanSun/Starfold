//
//  LatencyLevel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum LatencyLevel: Equatable {
    case low
    case moderate
    case high

    init(milliseconds: Double) {
        let lowLatencyLimit: Double = 50
        let moderateLatencyLimit: Double = 90

        self =
            switch milliseconds {
            case ..<lowLatencyLimit: .low
            case ..<moderateLatencyLimit: .moderate
            default: .high
            }
    }
}
