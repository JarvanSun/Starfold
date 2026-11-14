//
//  TouchPlatformDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit

@testable import StarfoldShared

extension TouchPlatform {
    static var dummy: TouchPlatform {
        .init(
            controllerCategory: "Touch Controller",
            hasDeviceHaptics: true,
            capabilities: .init(
                maxTouchPoints: 5,
                maxLayoutVersion: "4.1.0.0",
                maxManifestVersion: "2.0.0.0"
            )
        )
    }
}
