//
//  TouchResponseCurve.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchResponseCurve: String, Sendable, Hashable, Decodable {
    case circular
    case circularInverse = "circular-inverse"
}
