//
//  CandidateGatheringTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import XboxKit

@testable import StreamKit

struct CandidateGatheringTests {
    @Test
    func isSettledWhenGatheringCompleteThenIsTrue() {
        // Given
        var gathering = CandidateGathering()

        // When
        gathering.complete()

        // Then
        #expect(gathering.isSettled(at: .now, quietPeriod: quietPeriod))
    }

    @Test
    func isSettledWhenOnlyHostCandidatesWentQuietThenIsFalse() {
        // Given
        var gathering = CandidateGathering()
        let start = ContinuousClock.now

        // When
        gathering.add(candidate(type: "host"), at: start)

        // Then
        #expect(!gathering.isSettled(at: start + .seconds(1), quietPeriod: quietPeriod))
    }

    @Test(arguments: [(Duration.milliseconds(100), false), (.milliseconds(400), true)])
    func isSettledWhenPublicCandidateArrivedThenWaitsForTheQuietPeriod(
        elapsed: Duration,
        expected: Bool
    ) {
        // Given
        var gathering = CandidateGathering()
        let start = ContinuousClock.now

        // When
        gathering.add(candidate(type: "host"), at: start)
        gathering.add(candidate(type: "srflx"), at: start)

        // Then
        #expect(gathering.isSettled(at: start + elapsed, quietPeriod: quietPeriod) == expected)
        #expect(gathering.candidates.count == 2)
    }
}

private extension CandidateGatheringTests {
    var quietPeriod: Duration { .milliseconds(300) }

    func candidate(type: String) -> LocalICECandidate {
        .init(
            candidate: "candidate:1 1 udp 2122260223 192.0.2.10 50000 typ \(type)",
            sdpMid: "0",
            sdpMLineIndex: 0
        )
    }
}
