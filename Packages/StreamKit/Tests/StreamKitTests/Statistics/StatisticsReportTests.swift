//
//  StatisticsReportTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Testing

@testable import StreamKit

struct StatisticsReportTests {
    @Test
    func textThenAddsUpLatencyPartsAndSaysWhatTheEstimateLeavesOut() {
        // Given
        var statistics = StreamStatistics()
        statistics.roundTripMs = 10
        statistics.jitterBufferMs = 12
        statistics.decodeMs = 3
        statistics.displayMs = 9
        statistics.resolution = CGSize(width: 1920, height: 1080)
        statistics.upscaledTo = CGSize(width: 3840, height: 2160)

        // When
        let text = makeReport(statistics).text

        // Then
        #expect(text.hasPrefix("Starfold 1.0 · macOS 27\n"))
        #expect(
            text.contains(
                "Latency (estimate): 34 ms = round trip 10 ms + jitter buffer 12 ms + decode 3 ms + display 9 ms"
            )
        )
        #expect(text.contains("Not included:"))
        #expect(text.contains("Upscaled: 3840×2160 (MetalFX)"))
    }
}

private extension StatisticsReportTests {
    func makeReport(_ statistics: StreamStatistics) -> StatisticsReport {
        .init(statistics: statistics, appName: "Starfold", appVersion: "1.0", device: "macOS 27")
    }
}
