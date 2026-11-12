//
//  PollingBackoffTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct PollingBackoffTests {
    @Test(
        arguments: [
            (Duration.zero, Duration.milliseconds(100)),
            (.seconds(5), .milliseconds(250)),
            (.seconds(20), .milliseconds(500)),
            (.seconds(120), .seconds(1)),
        ]
    )
    func delayWhenWaitGrowsThenBacksOffToOnceASecond(elapsed: Duration, expected: Duration) {
        #expect(PollingBackoff().delay(after: elapsed) == expected)
    }
}
