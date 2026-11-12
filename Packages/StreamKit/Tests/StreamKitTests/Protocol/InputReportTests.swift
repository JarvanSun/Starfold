//
//  InputReportTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct InputReportTests {
    @Test
    func encodedWhenOneGamepadThenWritesIndexButtonsUpPositiveSticksAndFullRangeTriggers()
        throws
    {
        // Given
        let state = GamepadState(
            buttons: [.a, .nexus],
            leftStick: SIMD2(1, 1),
            rightStick: SIMD2(-1, -0.5),
            leftTrigger: 1,
            rightTrigger: 0.5
        )
        let report = InputReport(gamepads: [(2, state)])

        // When
        let bytes = [UInt8](try #require(report.encoded(sequence: 7, timestamp: 0)))

        // Then
        let record = ByteDecoding(bytes: Array(bytes[15...]))
        #expect(bytes.count == 14 + 1 + 23)
        #expect(bytes[0...1] == [2, 0])
        #expect(bytes[2...5] == [7, 0, 0, 0])
        #expect(bytes[14] == 1)
        #expect(record.bytes[0] == 2)
        #expect(record.uint16(at: 1) == 0x0012)
        #expect(record.int16(at: 3) == 32767)
        #expect(record.int16(at: 5) == 32767)
        #expect(record.int16(at: 7) == -32767)
        #expect(record.int16(at: 9) == -16383)
        #expect(record.uint16(at: 11) == 65535)
        #expect(record.uint16(at: 13) == 32767)
        #expect(record.uint32(at: 15) & 0x1000 != 0)
        #expect(record.uint32(at: 15) & 0x400 != 0)
        #expect(record.uint32(at: 15) & 0x30000 == 0x30000)
    }

    @Test
    func encodedWhenFramesAndGamepadThenWritesMetadataBeforeGamepad() throws {
        // Given
        let frame = FrameTimingRecord(
            rtpTimestamp: 90_000,
            firstPacketArrival: 1,
            submittedToDecoder: 2,
            decoded: 3,
            rendered: 4
        )
        let report = InputReport(frames: [frame], gamepads: [(5, GamepadState())])

        // When
        let bytes = [UInt8](try #require(report.encoded(sequence: 1, timestamp: 10)))

        // Then
        let metadata = ByteDecoding(bytes: Array(bytes[15...]))
        let gamepadStart = 14 + 1 + 28
        #expect(bytes[0...1] == [1 | 2, 0])
        #expect(bytes.count == 14 + (1 + 28) + (1 + 23))
        #expect(bytes[14] == 1)
        #expect(metadata.uint32(at: 0) == 90_000)
        #expect(bytes[gamepadStart] == 1)
        #expect(bytes[gamepadStart + 1] == 5)
    }

    @Test

    func encodedWhenNothingToSendThenIsNil() {
        #expect(InputReport().encoded(sequence: 1, timestamp: 0) == nil)
    }
}
