//
//  FramePacer.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

struct FramePacer: Sendable {
    struct Configuration: Sendable {
        var window: Int
        var rank: Int
        var minimumDelay: Double
        var maximumDelay: Double
        var margin: Double
        var decay: Double

        init(mode: PacingMode) {
            switch mode {
            case .lowLatency:
                self.init(
                    window: 2,
                    rank: 2,
                    minimumDelay: 0.004,
                    maximumDelay: 0.040,
                    margin: 0.002,
                    decay: 0.020
                )
            case .standard:
                self.init(
                    window: 4,
                    rank: 2,
                    minimumDelay: 0.008,
                    maximumDelay: 0.120,
                    margin: 0.004,
                    decay: 0.010
                )
            }
        }

        init(
            window: Int,
            rank: Int,
            minimumDelay: Double,
            maximumDelay: Double,
            margin: Double,
            decay: Double
        ) {
            self.window = window
            self.rank = rank
            self.minimumDelay = minimumDelay
            self.maximumDelay = maximumDelay
            self.margin = margin
            self.decay = decay
        }
    }

    private(set) var configuration: Configuration
    private(set) var delay: Double
    private(set) var lateFrames = 0

    private var previousRTP: UInt32?
    private var unwrappedRTP: Int64 = 0
    private var previousArrival: Double?
    private var lastPresentation: Double?
    private var floorBuckets: [(second: Int, transit: Double)] = []
    private var worstPerSecond: [(second: Int, lateness: Double)] = []

    init(mode: PacingMode) {
        configuration = .init(mode: mode)
        delay = configuration.minimumDelay
    }

    @discardableResult
    mutating func presentationTime(arrival: Double, rtp: UInt32) -> Double {
        let capture = captureTime(rtp: rtp)
        let transit = arrival - capture
        let second = Int(arrival.rounded(.down))
        let floor = transitFloor(adding: transit, at: second)
        updateDelay(lateness: transit - floor, at: second, arrival: arrival)

        previousArrival = arrival

        return schedule(capture + floor + delay, arrival: arrival)
    }

    private mutating func captureTime(rtp: UInt32) -> Double {
        if let previousRTP {
            unwrappedRTP += Int64(Int32(bitPattern: rtp &- previousRTP))
        }

        previousRTP = rtp

        return Double(unwrappedRTP) / rtpClockRate
    }

    private var rtpClockRate: Double { 90_000 }

    private mutating func transitFloor(adding transit: Double, at second: Int) -> Double {
        switch floorBuckets.last {
        case let last? where last.second == second:
            floorBuckets[floorBuckets.count - 1].transit = min(last.transit, transit)
        default:
            let oldestKept = second - floorWindow
            floorBuckets.append((second, transit))
            floorBuckets.removeAll { $0.second <= oldestKept }
        }

        return floorBuckets.map(\.transit).min() ?? transit
    }

    private var floorWindow: Int { 10 }

    private mutating func updateDelay(lateness: Double, at second: Int, arrival: Double) {
        switch worstPerSecond.last {
        case let last? where last.second == second:
            worstPerSecond[worstPerSecond.count - 1].lateness = max(last.lateness, lateness)
        default:
            let oldestKept = second - configuration.window
            worstPerSecond.append((second, lateness))
            worstPerSecond.removeAll { $0.second <= oldestKept }
        }

        let worstFirst = worstPerSecond.map(\.lateness).sorted(by: >)
        let covered = worstFirst[min(configuration.rank, worstFirst.count) - 1]
        let target = min(
            max(covered + configuration.margin, configuration.minimumDelay),
            configuration.maximumDelay
        )
        let elapsed = previousArrival.map { max(0, arrival - $0) } ?? 0
        delay = target > delay ? target : max(target, delay - configuration.decay * elapsed)
    }

    private mutating func schedule(_ planned: Double, arrival: Double) -> Double {
        let spaced = lastPresentation.map { max(planned, $0 + minimumSpacing) } ?? planned
        let presentation = max(spaced, arrival)

        if spaced < arrival {
            lateFrames += 1
        }

        lastPresentation = presentation
        return presentation
    }

    private var minimumSpacing: Double { 0.001 }

    mutating func setMode(_ mode: PacingMode) {
        configuration = .init(mode: mode)
        delay = min(max(delay, configuration.minimumDelay), configuration.maximumDelay)
    }

    mutating func takeLateFrames() -> Int {
        defer { lateFrames = 0 }

        return lateFrames
    }
}
