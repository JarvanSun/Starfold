//
//  TouchCapabilitiesOniOS.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreHaptics
import StarfoldShared
import TouchController

extension TouchCapabilities {
    init() {
        let maxTouchPoints = 10

        self.init(
            controllerCategory: TCGameControllerProductCategoryTouchController,
            maxTouchPoints: maxTouchPoints,
            hasDeviceHaptics: CHHapticEngine.capabilitiesForHardware().supportsHaptics
        )
    }
}
