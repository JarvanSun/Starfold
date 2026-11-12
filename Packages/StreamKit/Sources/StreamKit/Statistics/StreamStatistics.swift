//
//  StreamStatistics.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics

public struct StreamStatistics: Sendable, Equatable {
    public var resolution: CGSize?
    public var framesPerSecond: Double?
    public var bitrateMbps: Double?
    public var roundTripMs: Double?
    public var jitterBufferMs: Double?
    public var decodeMs: Double?
    public var packetLossPercent: Double?
    public var codec: String?
    public var displayMs: Double?
    public var upscaledTo: CGSize?
    public var isToneMapped = false
    public var path: NetworkPath?
    public var interface: String?

    var framesDropped: Int?

    public var estimatedLatencyMs: Double? {
        guard let roundTripMs else { return nil }

        return roundTripMs + (jitterBufferMs ?? 0) + (decodeMs ?? 0) + (displayMs ?? 0)
    }

    public init() {}
}
