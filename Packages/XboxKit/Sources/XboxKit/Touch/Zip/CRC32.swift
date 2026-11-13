//
//  CRC32.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct CRC32: Sendable {
    private let table: [UInt32]

    init() {
        let reversedPolynomial: UInt32 = 0xEDB8_8320

        table = (0...UInt32(UInt8.max)).map { byte in
            var remainder = byte

            for _ in 0..<UInt8.bitWidth {
                let isLowBitSet = remainder & 1 == 1
                remainder = isLowBitSet ? (remainder >> 1) ^ reversedPolynomial : remainder >> 1
            }

            return remainder
        }
    }

    func checksum(of bytes: some Sequence<UInt8>) -> UInt32 {
        var remainder = UInt32.max

        for byte in bytes {
            let tableIndex = Int((remainder ^ UInt32(byte)) & UInt32(UInt8.max))
            remainder = table[tableIndex] ^ (remainder >> UInt8.bitWidth)
        }

        return ~remainder
    }
}
