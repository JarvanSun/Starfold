//
//  ByteDecoding.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct ByteDecoding {
    let bytes: [UInt8]

    func int16(at offset: Int) -> Int16 {
        Int16(bitPattern: uint16(at: offset))
    }

    func uint16(at offset: Int) -> UInt16 {
        UInt16(bytes[offset]) | UInt16(bytes[offset + 1]) << 8
    }

    func uint32(at offset: Int) -> UInt32 {
        (0..<4).reduce(UInt32(0)) { $0 | UInt32(bytes[offset + $1]) << (8 * UInt32($1)) }
    }
}
