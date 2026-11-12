//
//  ClientMetadataTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct ClientMetadataTests {
    @Test
    func encodedThenIsFifteenBytesWithTypeEightAndSequenceZero() {
        // Given
        let metadata = ClientMetadata(maxTouchPoints: 0)

        // When
        let packet = [UInt8](metadata.encoded(timestamp: 1.5))

        // Then
        #expect(packet.count == 15)
        #expect(packet[0...1] == [8, 0])
        #expect(packet[2...5] == [0, 0, 0, 0])
        #expect(
            packet[6...13]
                == ArraySlice(withUnsafeBytes(of: (1.5).bitPattern.littleEndian, Array.init))
        )
        #expect(packet[14] == 0)
    }
}
