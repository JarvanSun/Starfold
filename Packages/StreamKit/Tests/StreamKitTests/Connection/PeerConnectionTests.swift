//
//  PeerConnectionTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Testing

@testable import StreamKit

struct PeerConnectionTests {
    @Test
    func createOfferThenGatheringEventsReachTheStream() async throws {
        // Given
        let (events, continuation) = AsyncStream<PeerEvent>.makeStream()
        let created = PeerConnection(
            runtime: StreamRuntime(),
            stunServers: [],
            events: { continuation.yield($0) }
        )
        let peer = try #require(created)
        defer { peer.close() }

        // When
        _ = try await peer.createOffer(videoBitrateKbps: nil)

        // Then
        #expect(await isGatheringReported(in: events, finishing: continuation))
    }
}

private extension PeerConnectionTests {
    func isGatheringReported(
        in events: AsyncStream<PeerEvent>,
        finishing continuation: AsyncStream<PeerEvent>.Continuation
    ) async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                for await event in events {
                    if case .gatheringComplete = event { return true }
                }

                return false
            }

            group.addTask {
                try? await Task.sleep(for: .seconds(10))
                continuation.finish()

                return false
            }

            let first = await group.next() ?? false

            continuation.finish()

            group.cancelAll()

            return first
        }
    }
}
