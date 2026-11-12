//
//  StatisticsReadoutTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

@MainActor
struct StatisticsReadoutTests {
    @Test
    func rowsThenFollowTheGivenKindsAndSkipMissingValues() {
        // Given
        let readout = makeReadout(kinds: [.frameRate, .codec, .resolution, .network])

        // When
        let kinds = readout.rows.map(\.kind)

        // Then
        #expect(kinds == [.frameRate, .resolution])
    }

    @Test
    func resolutionThenIsWidthByHeight() {
        #expect(makeReadout(kinds: [.resolution]).rows.map(\.value) == ["1920×1080"])
    }

    @Test
    func resolutionWhenQualityIsAutomaticThenSaysSo() {
        // Given
        let readout = makeReadout(kinds: [.resolution], usesAutomaticQuality: true)

        // When
        let value = readout.rows.first?.value ?? ""

        // Then
        #expect(value.hasPrefix("1920×1080"))
        #expect(value != "1920×1080")
    }

    @Test
    func loweredRowThenAppearsOnlyWhenTheHostLoweredTheQuality() {
        #expect(makeReadout(kinds: [.lowered]).rows.isEmpty)
        #expect(
            makeReadout(kinds: [.lowered], loweredFrom: .high).rows.first?.value.contains("1080p")
                == true
        )
    }

    @Test
    func latencyWithoutARoundTripThenIsAbsent() {
        #expect(makeReadout(kinds: []).latency == nil)
    }

    @Test(arguments: [(20.0, LatencyLevel.low), (60, .moderate), (120, .high)])
    func latencyThenIsRatedByItsLength(roundTrip: Double, level: LatencyLevel) {
        // Given
        var statistics = StreamStatistics()
        statistics.roundTripMs = roundTrip
        let readout = StatisticsReadout(
            statistics: statistics,
            kinds: [],
            usesAutomaticQuality: false,
            loweredFrom: nil
        )

        // Then
        #expect(readout.latency?.level == level)
        #expect(readout.latency?.value.contains("\(Int(roundTrip))") == true)
    }

    @Test
    func networkThenNamesThePathAndTheInterface() {
        // Given
        var statistics = StreamStatistics()
        statistics.path = .local
        statistics.interface = "wifi"
        let readout = StatisticsReadout(
            statistics: statistics,
            kinds: [.network],
            usesAutomaticQuality: false,
            loweredFrom: nil
        )

        // Then
        #expect(readout.rows.first?.value.hasSuffix(" · Wi-Fi") == true)
    }
}

private extension StatisticsReadoutTests {
    func makeReadout(
        kinds: [StatisticsRowKind],
        usesAutomaticQuality: Bool = false,
        loweredFrom: StreamQuality? = nil
    ) -> StatisticsReadout {
        var statistics = StreamStatistics()
        statistics.resolution = CGSize(width: 1920, height: 1080)
        statistics.framesPerSecond = 60

        return .init(
            statistics: statistics,
            kinds: kinds,
            usesAutomaticQuality: usesAutomaticQuality,
            loweredFrom: loweredFrom
        )
    }
}
