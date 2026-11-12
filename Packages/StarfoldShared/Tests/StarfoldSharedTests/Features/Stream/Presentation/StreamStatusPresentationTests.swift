//
//  StreamStatusPresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing

@testable import StarfoldShared

@MainActor
struct StreamStatusPresentationTests {
    @Test
    func titleThenIsDistinctForEachStatus() {
        // Given
        let statuses: [StreamStatus] = [
            .connecting,
            .queued(estimatedWait: nil),
            .queued(estimatedWait: "3 minutes"),
            .ended(.userStopped, advice: nil),
            .ended(.hostEnded, advice: nil),
            .ended(.connectionLost, advice: .networkDropped),
            .ended(.failed(""), advice: .consoleOffline),
        ]

        // When
        let titles = statuses.map { String(localized: $0.title) }

        // Then
        #expect(Set(titles).count == statuses.count)
        #expect(!titles.contains(""))
    }

    @Test
    func titleWhenQueuedWithAnEstimateThenIncludesIt() {
        // Given
        let status = StreamStatus.queued(estimatedWait: "3 minutes")

        // Then
        #expect(String(localized: status.title).contains("3 minutes"))
    }
}
