//
//  TouchAxisInput.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchAxisInput: String, Sendable, Hashable, Decodable, CaseIterable {
    case xy = "axisXY"
    case zy = "axisZY"
    case x = "axisX"
    case y = "axisY"
    case right = "axisRight"
    case left = "axisLeft"
    case up = "axisUp"
    case down = "axisDown"
}
