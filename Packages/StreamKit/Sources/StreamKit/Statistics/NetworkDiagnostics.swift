//
//  NetworkDiagnostics.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct NetworkDiagnostics {
    var video: [String: NSObject] = [:]
    var audio: [String: NSObject] = [:]
    var videoTimestamp = 0.0
    var audioTimestamp = 0.0
    var selectedPairID: String?
    var videoFormat: String?
    var audioFormat: String?

    private var ticks = 0
    private var roundTrips: [Double] = []
    private var videoStart: [String: NSObject] = [:]
    private var audioStart: [String: NSObject] = [:]
    private var videoStartTime = 0.0
    private var audioStartTime = 0.0

    mutating func noteRoundTrip(_ milliseconds: Double) {
        roundTrips.append(milliseconds)
    }

    mutating func tick() -> String? {
        ticks += 1

        takeFirstSamplesAsBaseline()

        guard ticks > 1, ticks % 5 == 1 else { return nil }

        defer { startNextPeriod() }
        return line
    }

    private mutating func takeFirstSamplesAsBaseline() {
        if videoStartTime == 0, !video.isEmpty {
            videoStart = video
            videoStartTime = videoTimestamp
        }

        if audioStartTime == 0, !audio.isEmpty {
            audioStart = audio
            audioStartTime = audioTimestamp
        }
    }

    private mutating func startNextPeriod() {
        videoStart = video
        audioStart = audio
        videoStartTime = videoTimestamp
        audioStartTime = audioTimestamp

        roundTrips.removeAll()
    }

    private var line: String {
        let videoSeconds = (videoTimestamp - videoStartTime) / 1_000_000
        let audioSeconds = (audioTimestamp - audioStartTime) / 1_000_000
        let videoKbps = videoSeconds > 0 ? videoDelta("bytesReceived") * 8 / videoSeconds / 1000 : 0
        let width = (video["frameWidth"] as? NSNumber)?.doubleValue ?? 0
        let height = (video["frameHeight"] as? NSNumber)?.doubleValue ?? 0
        let audioKbps =
            audioSeconds > 0
            ? Int((audioDelta("bytesReceived") * 8 / audioSeconds / 1000).rounded()) : 0
        let decoded = videoDelta("framesDecoded")

        return "Net 5s: rtt \(roundTripRange) ms | video \(Int(width))x\(Int(height)) "
            + "\(Int(videoKbps.rounded())) kbps \(bitsPerPixel(width: width, height: height)) bpp, "
            + "frames \(count(videoDelta("framesReceived")))/"
            + "\(count(decoded)) dropped \(count(videoDelta("framesDropped"))), "
            + "lost \(count(videoDelta("packetsLost"))) nack \(count(videoDelta("nackCount"))) "
            + "pli \(count(videoDelta("pliCount"))), "
            + "jb \(videoJitterBuffer) (target \(videoJitterBufferTarget)) ms, "
            + "decode \(decodeTime) ms, frame gap \(interFrameGap) ms, "
            + "freezes \(count(videoDelta("freezeCount"))) "
            + "(\(milliseconds(videoDelta("totalFreezesDuration"))) ms) "
            + "| audio \(audioKbps) kbps, jb \(audioJitterBuffer) (target \(audioJitterBufferTarget), "
            + "min \(audioJitterBufferMinimum)) ms, concealed \(concealedShare)"
    }

    private var roundTripRange: String {
        guard let shortest = roundTrips.min(), let longest = roundTrips.max() else { return "-" }

        return "\(Int(shortest.rounded()))…\(Int(longest.rounded()))"
    }

    private func bitsPerPixel(width: Double, height: Double) -> String {
        let decoded = videoDelta("framesDecoded")
        guard decoded > 0, width * height > 0 else { return "-" }

        return String(format: "%.3f", videoDelta("bytesReceived") * 8 / decoded / (width * height))
    }

    private func videoDelta(_ key: String) -> Double {
        delta(key, in: video, from: videoStart)
    }

    private var videoJitterBuffer: String {
        average(videoDelta("jitterBufferDelay"), over: videoDelta("jitterBufferEmittedCount"))
    }

    private var videoJitterBufferTarget: String {
        average(videoDelta("jitterBufferTargetDelay"), over: videoDelta("jitterBufferEmittedCount"))
    }

    private var decodeTime: String {
        average(videoDelta("totalDecodeTime"), over: videoDelta("framesDecoded"))
    }

    private var interFrameGap: String {
        let decoded = videoDelta("framesDecoded")
        guard decoded > 1 else { return "-" }

        let mean = videoDelta("totalInterFrameDelay") / decoded
        let variance = max(0, videoDelta("totalSquaredInterFrameDelay") / decoded - mean * mean)
        return "\(milliseconds(mean))±\(milliseconds(variance.squareRoot()))"
    }

    private var audioJitterBuffer: String {
        average(audioDelta("jitterBufferDelay"), over: audioDelta("jitterBufferEmittedCount"))
    }

    private var audioJitterBufferTarget: String {
        average(audioDelta("jitterBufferTargetDelay"), over: audioDelta("jitterBufferEmittedCount"))
    }

    private var audioJitterBufferMinimum: String {
        average(
            audioDelta("jitterBufferMinimumDelay"),
            over: audioDelta("jitterBufferEmittedCount")
        )
    }

    private func average(_ total: Double, over count: Double) -> String {
        count > 0 ? milliseconds(total / count) : "-"
    }

    private func count(_ value: Double) -> String {
        "\(Int(value.rounded()))"
    }

    private func milliseconds(_ seconds: Double) -> String {
        seconds.isFinite ? "\(Int((seconds * 1000).rounded()))" : "-"
    }

    private var concealedShare: String {
        let samples = audioDelta("totalSamplesReceived")
        guard samples > 0 else { return "-" }

        return String(format: "%.1f%%", audioDelta("concealedSamples") / samples * 100)
    }

    private func audioDelta(_ key: String) -> Double {
        delta(key, in: audio, from: audioStart)
    }

    private func delta(_ key: String, in now: [String: NSObject], from start: [String: NSObject])
        -> Double
    {
        let current = (now[key] as? NSNumber)?.doubleValue ?? 0
        let previous = (start[key] as? NSNumber)?.doubleValue ?? 0
        return current - previous
    }
}
