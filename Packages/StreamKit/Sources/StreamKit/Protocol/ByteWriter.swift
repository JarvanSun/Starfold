//
//  ByteWriter.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ByteWriter {
    private(set) var data = Data()

    mutating func appendHeader(types: [InputReportType], sequence: UInt32, timestamp: Double) {
        append(types.reduce(UInt16(0)) { $0 | $1.rawValue })
        append(sequence)
        append(timestamp.bitPattern)
    }

    mutating func append(_ value: UInt8) {
        data.append(value)
    }

    mutating func append(_ value: UInt16) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    mutating func append(_ value: Int16) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    mutating func append(_ value: UInt32) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }

    mutating func append(_ value: UInt64) {
        withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
    }
}
