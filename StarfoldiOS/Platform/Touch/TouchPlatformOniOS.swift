//
//  TouchPlatformOniOS.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreHaptics
import StarfoldShared
import StreamKit
import TouchController

extension TouchPlatform {
    init() {
        self.init(
            controllerCategory: TCGameControllerProductCategoryTouchController,
            hasDeviceHaptics: CHHapticEngine.capabilitiesForHardware().supportsHaptics,
            capabilities: .init(
                maxTouchPoints: 5,
                maxLayoutVersion: "4.1.0.0",
                maxManifestVersion: "2.0.0.0"
            )
        )
    }
}
