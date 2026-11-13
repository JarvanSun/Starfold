//
//  TouchPlatform.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit

public struct TouchPlatform {
    let controllerCategory: String
    let hasDeviceHaptics: Bool
    let capabilities: TouchCapabilities

    public init(
        controllerCategory: String,
        hasDeviceHaptics: Bool,
        capabilities: TouchCapabilities
    ) {
        self.controllerCategory = controllerCategory
        self.hasDeviceHaptics = hasDeviceHaptics
        self.capabilities = capabilities
    }
}
