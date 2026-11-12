//
//  StatisticsReport.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/10/01.
//

import CoreGraphics
import Foundation

public struct StatisticsReport: Sendable {
    private let statistics: StreamStatistics
    private let appName: String
    private let appVersion: String
    private let device: String

    public var text: String {
        var lines = [
            "\(appName) \(appVersion) · \(device)",
            "Latency (estimate): \(milliseconds(statistics.estimatedLatencyMs)) = round trip \(milliseconds(statistics.roundTripMs)) + jitter buffer \(milliseconds(statistics.jitterBufferMs)) + decode \(milliseconds(statistics.decodeMs)) + display \(milliseconds(statistics.displayMs))",
            "Not included: controller input and the host's capture and encode, which the host doesn't report.",
            "Resolution: \(size(statistics.resolution))"
                + (statistics.codec.map { " \($0)" } ?? ""),
        ]

        if let upscaled = statistics.upscaledTo {
            lines.append("Upscaled: \(size(upscaled)) (MetalFX)")
        }

        if statistics.isToneMapped {
            lines.append("Dynamic range: SDR stream tone mapped to HDR")
        }

        lines.append(
            "Frame rate: " + (statistics.framesPerSecond.map { "\(Int($0.rounded())) fps" } ?? "–")
        )
        lines.append(
            "Bitrate: " + (statistics.bitrateMbps.map { String(format: "%.1f Mbps", $0) } ?? "–")
        )
        lines.append(
            "Packet loss: "
                + (statistics.packetLossPercent.map { String(format: "%.1f%%", $0) } ?? "–")
        )

        if let dropped = statistics.framesDropped {
            lines.append("Frames dropped: \(dropped)")
        }

        return lines.joined(separator: "\n")
    }

    public init(statistics: StreamStatistics, appName: String, appVersion: String, device: String) {
        self.statistics = statistics
        self.appName = appName
        self.appVersion = appVersion
        self.device = device
    }
}

private extension StatisticsReport {
    func milliseconds(_ value: Double?) -> String {
        value.map { "\(Int($0.rounded())) ms" } ?? "–"
    }

    func size(_ value: CGSize?) -> String {
        value.map { "\(Int($0.width))×\(Int($0.height))" } ?? "–"
    }
}
