//
//  StreamStatisticsTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct StreamStatisticsTests {
    @Test
    func estimatedLatencyMsWhenRoundTripUnknownThenIsNil() {
        // Given
        var statistics = StreamStatistics()

        // When
        statistics.jitterBufferMs = 12
        statistics.decodeMs = 3

        // Then
        #expect(statistics.estimatedLatencyMs == nil)
    }

    @Test

    func estimatedLatencyMsThenAddsRoundTripJitterBufferDecodeAndDisplay() {
        // Given
        var statistics = StreamStatistics()

        // When
        statistics.jitterBufferMs = 12
        statistics.decodeMs = 3
        statistics.roundTripMs = 10
        statistics.displayMs = 9

        // Then
        #expect(statistics.estimatedLatencyMs == 34)
    }
}
