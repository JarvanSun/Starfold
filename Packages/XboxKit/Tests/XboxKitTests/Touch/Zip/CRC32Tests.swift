//
//  CRC32Tests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct CRC32Tests {
    @Test(arguments: [("123456789", UInt32(0xCBF4_3926)), ("", 0), ("a", 0xE8B7_BE43)])
    func checksumThenMatchesTheZipCheckValue(text: String, expected: UInt32) {
        #expect(CRC32().checksum(of: Array(text.utf8)) == expected)
    }
}
