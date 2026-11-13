//
//  HostICECandidate.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct HostICECandidate {
    let line: String

    var expanded: [String] {
        switch (isDiscarded, teredoAddress) {
        case (true, _): []
        case (false, let teredo?):
            [
                "candidate:10 1 UDP 1 \(teredo.publicIPv4Address) 9002 typ host",
                "candidate:11 1 UDP 1 \(teredo.publicIPv4Address) \(teredo.mappedPort) typ host",
                line,
            ]
        case (false, nil): [line]
        }
    }

    private var isDiscarded: Bool {
        line.hasPrefix("end-of-candidates") || line.isEmpty || isUDPWithTCPType
    }

    private var isUDPWithTCPType: Bool {
        let lowercased = line.lowercased()
        return lowercased.contains(" udp ") && lowercased.contains("tcptype")
    }

    private var teredoAddress: TeredoAddress? {
        let fields = line.split(separator: " ", omittingEmptySubsequences: true)
        guard fields.count > 5 else {
            return nil
        }

        let address = String(fields[4])
        guard address.hasPrefix("2001:") else {
            return nil
        }

        return TeredoAddress(address)
    }

    init(_ raw: String) {
        var line = raw.trimmingCharacters(in: .whitespaces)

        if line.hasPrefix("a=") {
            line.removeFirst(2)
        }

        self.line = line
    }
}
