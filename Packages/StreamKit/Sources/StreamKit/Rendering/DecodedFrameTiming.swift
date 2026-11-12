//
//  DecodedFrameTiming.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import QuartzCore

public struct DecodedFrameTiming: Sendable {
    let rtpTimestamp: UInt32
    let arrival: CFTimeInterval
}
