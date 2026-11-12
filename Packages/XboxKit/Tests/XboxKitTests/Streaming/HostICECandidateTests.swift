//
//  HostICECandidateTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct HostICECandidateTests {
    @Test
    func expandedWhenAddressIsTeredoThenAddsTwoIPv4CandidatesBeforeOriginal() {
        // Given
        let candidate = HostICECandidate(
            "a=candidate:1 1 UDP 100 2001:0:4136:e378:8000:2bce:34ff:8efa 9002 typ host "
        )

        // When / Then
        #expect(
            candidate.expanded == [
                "candidate:10 1 UDP 1 203.0.113.5 9002 typ host",
                "candidate:11 1 UDP 1 203.0.113.5 54321 typ host",
                "candidate:1 1 UDP 100 2001:0:4136:e378:8000:2bce:34ff:8efa 9002 typ host",
            ]
        )
    }

    @Test(
        arguments: [
            (
                "a=candidate:2 1 UDP 1 198.51.100.7 9002 typ host ",
                ["candidate:2 1 UDP 1 198.51.100.7 9002 typ host"]
            ),
            ("a=end-of-candidates", []),
            ("candidate:3 1 UDP 1 10.0.0.2 9 typ host tcptype active", []),
            ("   ", []),
        ]
    )
    func expandedThenDropsPrefixEndOfCandidatesAndUDPTCPTypeLines(raw: String, expected: [String]) {
        #expect(HostICECandidate(raw).expanded == expected)
    }
}
