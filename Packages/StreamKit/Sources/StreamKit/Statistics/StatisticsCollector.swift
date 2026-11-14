//
//  StatisticsCollector.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics
import Foundation
@preconcurrency import LiveKitWebRTC
import os

struct StatisticsCollector {
    private struct VideoTotals {
        let bytes: Double
        let timestampMicroseconds: Double
        let lost: Double
        let received: Double
    }

    private let log = Logger(category: .stream)

    private var previousVideoTotals: VideoTotals?
    private var lastResolution: CGSize?
    private var diagnostics = NetworkDiagnostics()

    mutating func collect(_ report: [String: LKRTCStatistics]) -> StreamStatistics {
        var statistics = StreamStatistics()
        let selectedPairID =
            report.values.first { $0.type == "transport" }?.values["selectedCandidatePairId"]
            as? String

        for entry in report.values {
            switch entry.type {
            case "inbound-rtp" where entry.values["kind"] as? String == "video":
                recordVideo(entry, report: report, into: &statistics)
            case "inbound-rtp" where entry.values["kind"] as? String == "audio":
                recordAudio(entry, report: report)
            case "candidate-pair" where entry.id == selectedPairID:
                recordSelectedPair(entry, report: report, into: &statistics)
            default:
                break
            }
        }

        if let line = diagnostics.tick() {
            log.info("\(line, privacy: .public)")
        }

        return statistics
    }

    private mutating func recordVideo(
        _ entry: LKRTCStatistics,
        report: [String: LKRTCStatistics],
        into statistics: inout StreamStatistics
    ) {
        let values = entry.values
        noteResolution(
            width: number(values["frameWidth"]),
            height: number(values["frameHeight"]),
            in: &statistics
        )

        statistics.framesPerSecond = number(values["framesPerSecond"])
        diagnostics.video = values
        diagnostics.videoTimestamp = entry.timestamp_us

        if let dropped = number(values["framesDropped"]) {
            statistics.framesDropped = Int(dropped)
        }

        if let delay = number(values["jitterBufferDelay"]),
            let emitted = number(values["jitterBufferEmittedCount"]),
            emitted > 0
        {
            statistics.jitterBufferMs = delay / emitted * 1000
        }

        if let decodeTime = number(values["totalDecodeTime"]),
            let decoded = number(values["framesDecoded"]),
            decoded > 0
        {
            statistics.decodeMs = decodeTime / decoded * 1000
        }

        recordVideoRates(values, timestamp: entry.timestamp_us, into: &statistics)
        recordVideoCodec(values, report: report, into: &statistics)
    }

    private mutating func noteResolution(
        width: Double?,
        height: Double?,
        in statistics: inout StreamStatistics
    ) {
        guard let width, let height else { return }

        statistics.resolution = CGSize(width: width, height: height)

        if statistics.resolution != lastResolution {
            log.info("Receiving \(Int(width))x\(Int(height))")

            lastResolution = statistics.resolution
        }
    }

    private func number(_ value: NSObject?) -> Double? {
        (value as? NSNumber)?.doubleValue
    }

    private mutating func recordVideoRates(
        _ values: [String: NSObject],
        timestamp: Double,
        into statistics: inout StreamStatistics
    ) {
        let totals = VideoTotals(
            bytes: number(values["bytesReceived"]) ?? 0,
            timestampMicroseconds: timestamp,
            lost: number(values["packetsLost"]) ?? 0,
            received: number(values["packetsReceived"]) ?? 0
        )

        if let previous = previousVideoTotals, timestamp > previous.timestampMicroseconds {
            let seconds = (timestamp - previous.timestampMicroseconds) / 1_000_000
            statistics.bitrateMbps = (totals.bytes - previous.bytes) * 8 / seconds / 1_000_000

            let lostDelta = totals.lost - previous.lost
            let receivedDelta = totals.received - previous.received

            if lostDelta + receivedDelta > 0 {
                statistics.packetLossPercent = max(0, lostDelta) / (lostDelta + receivedDelta) * 100
            }
        }

        previousVideoTotals = totals
    }

    private mutating func recordVideoCodec(
        _ values: [String: NSObject],
        report: [String: LKRTCStatistics],
        into statistics: inout StreamStatistics
    ) {
        guard let codecID = values["codecId"] as? String, let codec = report[codecID] else {
            return
        }

        let mimeType = codec.values["mimeType"] as? String
        let format = "\(mimeType ?? "?") \(codec.values["sdpFmtpLine"] as? String ?? "")"

        if format != diagnostics.videoFormat {
            diagnostics.videoFormat = format
            log.info("Video codec: \(format, privacy: .public)")
        }

        statistics.codec = mimeType?.replacingOccurrences(of: "video/", with: "")
    }

    private mutating func recordAudio(_ entry: LKRTCStatistics, report: [String: LKRTCStatistics]) {
        diagnostics.audio = entry.values
        diagnostics.audioTimestamp = entry.timestamp_us

        guard let codecID = entry.values["codecId"] as? String, let codec = report[codecID] else {
            return
        }

        let channels = (codec.values["channels"] as? NSNumber)?.intValue ?? 0
        let mimeType = codec.values["mimeType"] as? String ?? "?"
        let format = "\(mimeType) \(channels) ch \(codec.values["sdpFmtpLine"] as? String ?? "")"

        if format != diagnostics.audioFormat {
            diagnostics.audioFormat = format
            log.info("Audio codec: \(format, privacy: .public)")
        }
    }

    private mutating func recordSelectedPair(
        _ entry: LKRTCStatistics,
        report: [String: LKRTCStatistics],
        into statistics: inout StreamStatistics
    ) {
        let values = entry.values

        if let roundTrip = number(values["currentRoundTripTime"]) {
            statistics.roundTripMs = roundTrip * 1000

            diagnostics.noteRoundTrip(roundTrip * 1000)
        }

        let local = (values["localCandidateId"] as? String).flatMap { report[$0]?.values }
        let remote = (values["remoteCandidateId"] as? String).flatMap { report[$0]?.values }

        if entry.id != diagnostics.selectedPairID {
            diagnostics.selectedPairID = entry.id

            let path =
                "\(CandidateSummary(statistics: local).text) → \(CandidateSummary(statistics: remote).text)"
            log.info("Selected path: \(path, privacy: .public)")
        }

        statistics.path = .init(
            localType: local?["candidateType"] as? String,
            remoteType: remote?["candidateType"] as? String
        )
        statistics.interface = local?["networkType"] as? String
    }
}
