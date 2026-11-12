//
//  FrameTimingRecord.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct FrameTimingRecord: Equatable, Sendable {
    var rtpTimestamp: UInt32
    var firstPacketArrival: UInt32
    var submittedToDecoder: UInt32
    var decoded: UInt32
    var rendered: UInt32
}
