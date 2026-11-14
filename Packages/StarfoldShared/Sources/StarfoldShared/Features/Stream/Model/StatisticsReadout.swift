//
//  StatisticsReadout.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import XboxKit

public struct StatisticsReadout {
    private let statistics: StreamStatistics
    private let kinds: [StatisticsRowKind]
    private let usesAutomaticQuality: Bool
    private let loweredFrom: StreamQuality?
    private let separator = " · "

    public var latency: StatisticsLatency? {
        statistics.estimatedLatencyMs.map(latency(of:))
    }

    private func latency(of milliseconds: Double) -> StatisticsLatency {
        let duration = duration(milliseconds)
        return .init(
            value: String(
                localized: "stream.statistics.latency.value \(duration)",
                bundle: .module
            ),
            level: LatencyLevel(milliseconds: milliseconds)
        )
    }

    private func duration(_ milliseconds: Double) -> String {
        Duration.milliseconds(milliseconds)
            .formatted(.units(allowed: [.milliseconds], width: .abbreviated))
    }

    public var rows: [StatisticsRow] {
        kinds.compactMap(row(of:))
    }

    private func row(of kind: StatisticsRowKind) -> StatisticsRow? {
        value(of: kind).map { .init(kind: kind, value: $0) }
    }

    private func value(of kind: StatisticsRowKind) -> String? {
        switch kind {
        case .resolution: statistics.resolution.map(resolution(_:))
        case .codec: statistics.codec
        case .upscaled: statistics.upscaledTo.map(upscaled(to:))
        case .dynamicRange: toneMapping
        case .lowered: loweredFrom.map(lowered(from:))
        case .frameRate: statistics.framesPerSecond.map(frameRate(_:))
        case .bitrate: statistics.bitrateMbps.map(bitrate(_:))
        case .network: network
        case .roundTrip: statistics.roundTripMs.map(duration(_:))
        case .decode: statistics.decodeMs.map(duration(_:))
        case .jitterBuffer: statistics.jitterBufferMs.map(duration(_:))
        case .display: statistics.displayMs.map(duration(_:))
        case .packetLoss: statistics.packetLossPercent.map(percent(_:))
        }
    }

    private func resolution(_ size: CGSize) -> String {
        let size = dimensions(of: size)

        return switch usesAutomaticQuality {
        case true:
            String(localized: "stream.statistics.resolution.automatic \(size)", bundle: .module)
        case false: size
        }
    }

    private func dimensions(of size: CGSize) -> String {
        "\(Int(size.width))×\(Int(size.height))"
    }

    private func upscaled(to size: CGSize) -> String {
        [dimensions(of: size), "MetalFX"].joined(separator: separator)
    }

    private func lowered(from quality: StreamQuality) -> String {
        String(localized: "stream.statistics.loweredFrom \(quality.label)", bundle: .module)
    }

    private func frameRate(_ framesPerSecond: Double) -> String {
        let number = framesPerSecond.formatted(.number.precision(.fractionLength(0)))
        return String(localized: "stream.statistics.frameRate.value \(number)", bundle: .module)
    }

    private func bitrate(_ megabitsPerSecond: Double) -> String {
        let number = megabitsPerSecond.formatted(.number.precision(.fractionLength(1)))
        return String(localized: "stream.statistics.bitrate.value \(number)", bundle: .module)
    }

    private func percent(_ value: Double) -> String {
        (value / 100).formatted(.percent.precision(.fractionLength(1)))
    }

    private var network: String? {
        guard let path = statistics.path else { return nil }

        return [String(localized: path.title), statistics.interface.flatMap(name(ofInterface:))]
            .compactMap { $0 }
            .joined(separator: separator)
    }

    private func name(ofInterface type: String) -> String? {
        switch type {
        case "wifi": "Wi-Fi"
        case "ethernet": String(localized: "stream.statistics.network.ethernet", bundle: .module)
        default: nil
        }
    }

    public init(
        statistics: StreamStatistics,
        kinds: [StatisticsRowKind],
        usesAutomaticQuality: Bool,
        loweredFrom: StreamQuality?
    ) {
        self.statistics = statistics
        self.kinds = kinds
        self.usesAutomaticQuality = usesAutomaticQuality
        self.loweredFrom = loweredFrom
    }

    private var toneMapping: String? {
        switch statistics.isToneMapped {
        case true: String(localized: "stream.statistics.toneMapping", bundle: .module)
        case false: nil
        }
    }
}
