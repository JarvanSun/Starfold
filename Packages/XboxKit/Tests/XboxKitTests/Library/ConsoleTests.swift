//
//  ConsoleTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct ConsoleTests {
    @Test(
        arguments: [
            (Console.PowerState.on, true),
            (.connectedStandby, true),
            (.off, false),
            (.unknown, false),
        ]
    )
    func isReachableThenOnlyForOnAndConnectedStandby(
        powerState: Console.PowerState,
        expected: Bool
    ) {
        // Given
        let console = Console(
            id: "F400",
            name: "Living room",
            consoleType: "XboxSeriesX",
            powerState: powerState
        )

        // Then
        #expect(console.isReachable == expected)
    }

    @Test
    func encodeThenKeepsStoredWarningKeys() throws {
        // Given
        let console = Console(
            id: "F400",
            name: "Living room",
            consoleType: "XboxSeriesX",
            powerState: .on,
            hasOutOfHomeWarning: true,
            hasWirelessWarning: false
        )

        // When
        let json = try #require(
            try JSONSerialization.jsonObject(with: JSONEncoder().encode(console)) as? [String: Any]
        )

        // Then
        #expect(json["outOfHomeWarning"] as? Bool == true)
        #expect(json["wirelessWarning"] as? Bool == false)
        #expect(json["powerState"] as? String == "On")
    }
}
