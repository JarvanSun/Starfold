//
//  TouchCapabilities.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchCapabilities {
    let controllerCategory: String
    let maxTouchPoints: Int
    let hasDeviceHaptics: Bool

    public init(controllerCategory: String, maxTouchPoints: Int, hasDeviceHaptics: Bool) {
        self.controllerCategory = controllerCategory
        self.maxTouchPoints = maxTouchPoints
        self.hasDeviceHaptics = hasDeviceHaptics
    }
}
