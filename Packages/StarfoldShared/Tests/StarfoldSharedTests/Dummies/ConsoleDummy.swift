//
//  ConsoleDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

extension Console {
    static func dummyLivingRoom(powerState: PowerState) -> Console {
        .init(id: "X", name: "Living room", consoleType: "XboxSeriesX", powerState: powerState)
    }

    static var dummyBedroom: Console {
        .init(
            id: "A",
            name: "Bedroom",
            consoleType: "XboxSeriesS",
            powerState: .connectedStandby,
            hasWirelessWarning: true
        )
    }
}
