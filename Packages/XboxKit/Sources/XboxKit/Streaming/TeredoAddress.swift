//
//  TeredoAddress.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct TeredoAddress: Equatable {
    let publicIPv4Address: String
    let mappedPort: UInt16

    init?(_ address: String) {
        var groups = address.split(separator: ":", omittingEmptySubsequences: false)
            .map(String.init)

        if let gap = groups.firstIndex(of: ""), groups.count < 8 {
            let zeroGroups = Array(repeating: "0", count: 8 - groups.count + 1)
            groups.replaceSubrange(gap...gap, with: zeroGroups)
        }

        let words = groups.compactMap { UInt16($0.isEmpty ? "0" : $0, radix: 16) }
        guard words.count == 8, words[0] == 0x2001, words[1] == 0 else {
            return nil
        }

        let client = (UInt32(words[6]) << 16 | UInt32(words[7])) ^ 0xFFFF_FFFF
        mappedPort = words[5] ^ 0xFFFF
        publicIPv4Address = [24, 16, 8, 0]
            .map { String((client >> UInt32($0)) & 0xFF) }
            .joined(separator: ".")
    }
}
