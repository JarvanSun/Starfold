//
//  TouchSensorKind.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchSensorKind: Sendable, Hashable {
    case gyroscope
    case accelerometer
    case blank
    case unsupported(type: String)
}
