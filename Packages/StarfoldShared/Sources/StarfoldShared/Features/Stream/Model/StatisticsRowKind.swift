//
//  StatisticsRowKind.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum StatisticsRowKind: Hashable, Sendable {
    case resolution
    case codec
    case upscaled
    case dynamicRange
    case lowered
    case frameRate
    case bitrate
    case network
    case roundTrip
    case decode
    case jitterBuffer
    case display
    case packetLoss
}
