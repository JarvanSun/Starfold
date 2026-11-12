//
//  FramePacerTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct FramePacerTests {
    @Test
    func presentationTimeWhenStreamSteadyThenKeepsSmallestBufferAndGameSpacing() {
        // Given / When
        let run = simulate(.standard, frames: 600)

        // Then
        #expect(
            abs(run.pacer.delay - FramePacer.Configuration(mode: .standard).minimumDelay) < 0.0005
        )
        #expect(run.lateFrames.isEmpty)
        #expect(abs((run.shown[599] - run.shown[598]) - 1.0 / 60) < 0.0001)
    }

    @Test

    func presentationTimeWhenStallsRepeatThenAbsorbsThemAtGameSpacing() {
        // Given / When
        let run = simulate(.standard, frames: 900, stallEvery: 60)

        // Then
        let gaps = zip(run.shown[600...].dropFirst(), run.shown[600...]).map { $0 - $1 }
        #expect(run.lateFrames.contains { $0 < 300 })
        #expect(!run.lateFrames.contains { $0 >= 600 })
        #expect(gaps.allSatisfy { abs($0 - 1.0 / 60) < 0.0005 })
        #expect(run.pacer.delay <= 0.110)
    }

    @Test

    func presentationTimeWhenOneStallThenReturnsToSmallestBuffer() {
        // Given
        var pacer = FramePacer(mode: .standard)

        // When
        for index in 0..<600 {
            let isHeldByStall = (120..<129).contains(index)
            let arrival = isHeldByStall ? Double(129) / 60 + 0.010 : Double(index) / 60 + 0.010
            pacer.presentationTime(arrival: 1000 + arrival, rtp: UInt32(index * 1500))
        }

        // Then
        #expect(abs(pacer.delay - FramePacer.Configuration(mode: .standard).minimumDelay) < 0.001)
    }

    @Test

    func setModeWhenSwitchedMidStreamThenKeepsOrderAndMovesBufferWithinNewBounds() {
        // Given
        var pacer = FramePacer(mode: .standard)
        var shown: [Double] = []

        // When
        for index in 0..<300 {
            if index == 150 {
                pacer.setMode(.lowLatency)
            }

            shown.append(
                pacer.presentationTime(
                    arrival: 1000 + stalledArrival(of: index, stallEvery: 60),
                    rtp: UInt32(index * 1500)
                )
            )
        }

        // Then
        #expect(zip(shown.dropFirst(), shown).allSatisfy { $0 > $1 })
        #expect(pacer.delay <= FramePacer.Configuration(mode: .lowLatency).maximumDelay)
    }

    @Test

    func presentationTimeWhenLowLatencyThenBuffersAtMostFortyMilliseconds() {
        // Given / When
        let run = simulate(.lowLatency, frames: 900, stallEvery: 60)

        // Then
        #expect(run.pacer.delay <= 0.040)
        #expect(run.lateFrames.contains { $0 >= 600 })
    }

    @Test

    func presentationTimeWhenRTPWrapsThenKeepsSpacing() {
        // Given / When
        let run = simulate(.standard, frames: 120, rtpStart: UInt32.max - 30_000)

        // Then
        let gaps = zip(run.shown.dropFirst(), run.shown).map { $0 - $1 }
        #expect(run.lateFrames.isEmpty)
        #expect(gaps.allSatisfy { abs($0 - 1.0 / 60) < 0.0005 })
    }
}

private extension FramePacerTests {
    struct PacingRun {
        let pacer: FramePacer
        let shown: [Double]
        let lateFrames: [Int]
    }

    func simulate(
        _ mode: PacingMode,
        frames: Int,
        stallEvery: Int? = nil,
        rtpStart: UInt32 = 0
    ) -> PacingRun {
        var pacer = FramePacer(mode: mode)
        var shown: [Double] = []
        var lateFrames: [Int] = []

        for index in 0..<frames {
            let arrival =
                stallEvery.map { stalledArrival(of: index, stallEvery: $0) }
                ?? steadyArrival(of: index)
            let lateBefore = pacer.lateFrames
            shown.append(
                pacer.presentationTime(
                    arrival: 1000 + arrival,
                    rtp: rtpStart &+ UInt32(index * 1500)
                )
            )

            if pacer.lateFrames > lateBefore {
                lateFrames.append(index)
            }
        }

        return .init(pacer: pacer, shown: shown, lateFrames: lateFrames)
    }

    func steadyArrival(of index: Int) -> Double {
        Double(index) / 60 + 0.010
    }

    func stalledArrival(of index: Int, stallEvery: Int, stallLength: Int = 6) -> Double {
        let isHeld = index >= stallEvery && index % stallEvery < stallLength
        guard isHeld else { return steadyArrival(of: index) }

        return Double(index - index % stallEvery + stallLength) / 60 + 0.010
    }
}
