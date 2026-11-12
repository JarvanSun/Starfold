//
//  ServerInputPacketTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct ServerInputPacketTests {
    @Test
    func eventsWhenServerMetadataThenReadsHeightBeforeWidth() {
        // Given
        var data = Data([16, 0])
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1080).littleEndian, Array.init))
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1920).littleEndian, Array.init))

        // When
        let events = ServerInputPacket(data: data).events

        // Then
        #expect(events == [.videoSize(width: 1920, height: 1080)])
    }

    @Test

    func eventsWhenVibrationThenMapsPercentagesToUnitsAndMilliseconds() {
        // Given
        let data = Data([128, 0, 0, 1, 100, 50, 0, 25, 0xF4, 0x01, 0x0A, 0x00, 2])

        // When
        let events = ServerInputPacket(data: data).events

        // Then
        let expected = VibrationEffect(
            gamepadIndex: 1,
            leftMotor: 1,
            rightMotor: 0.5,
            leftTrigger: 0,
            rightTrigger: 0.25,
            duration: .milliseconds(500),
            delay: .milliseconds(10),
            repeatCount: 2
        )
        #expect(events == [.vibration(expected)])
    }
}
