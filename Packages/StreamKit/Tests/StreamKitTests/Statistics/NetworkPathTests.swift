//
//  NetworkPathTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct NetworkPathTests {
    @Test(
        arguments: [
            ("host", "host", StreamStatistics.NetworkPath.local),
            ("srflx", "host", .internet),
            ("host", "prflx", .internet),
            ("relay", "host", .relay),
        ]
    )
    func initThenIsLocalOnlyForTwoHostsAndRelayWhenEitherEndIsRelayed(
        localType: String,
        remoteType: String,
        expected: StreamStatistics.NetworkPath
    ) {
        #expect(
            StreamStatistics.NetworkPath(localType: localType, remoteType: remoteType) == expected
        )
    }
}
