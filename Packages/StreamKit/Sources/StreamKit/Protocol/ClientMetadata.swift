//
//  ClientMetadata.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ClientMetadata {
    let maxTouchPoints: UInt8

    func encoded(timestamp: Double) -> Data {
        var writer = ByteWriter()
        writer.appendHeader(types: [.clientMetadata], sequence: 0, timestamp: timestamp)
        writer.append(maxTouchPoints)
        return writer.data
    }
}
