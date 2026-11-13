//
//  TouchCapabilitiesDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

@testable import StarfoldShared

extension TouchCapabilities {
    static var dummy: TouchCapabilities {
        .init(controllerCategory: "Touch Controller", maxTouchPoints: 10, hasDeviceHaptics: true)
    }
}
