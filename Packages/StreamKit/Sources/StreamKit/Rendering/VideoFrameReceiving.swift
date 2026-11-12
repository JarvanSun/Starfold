//
//  VideoFrameReceiving.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreVideo

public protocol VideoFrameReceiving: AnyObject, Sendable {
    func render(_ pixelBuffer: CVPixelBuffer, timing: DecodedFrameTiming)
}
