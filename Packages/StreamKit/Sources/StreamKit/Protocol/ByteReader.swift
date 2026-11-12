//
//  ByteReader.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ByteReader {
    private let bytes: [UInt8]

    private var offset = 0

    init(_ data: Data) {
        bytes = [UInt8](data)
    }

    mutating func readUInt8() -> UInt8? {
        guard offset < bytes.count else { return nil }

        defer { offset += 1 }
        return bytes[offset]
    }

    mutating func readUInt16() -> UInt16? {
        guard offset + 2 <= bytes.count else { return nil }

        defer { offset += 2 }
        return UInt16(bytes[offset]) | UInt16(bytes[offset + 1]) << 8
    }

    mutating func readUInt32() -> UInt32? {
        guard offset + 4 <= bytes.count else { return nil }

        defer { offset += 4 }
        return (0..<4).reduce(UInt32(0)) { $0 | UInt32(bytes[offset + $1]) << (8 * UInt32($1)) }
    }
}
