//
//  GSSVClientTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct GSSVClientTests {
    @Test
    func consolesWhenTokenIsRejectedThenRefreshesItAndRetriesOnce() async throws {
        // Given
        let server = XboxServerStub()
        let consolesURL = "\(XboxEndpoint.homeRegion.rawValue)/v6/servers/home"
        server.on(consolesURL, status: 401, json: "{}")
        server.on(
            consolesURL,
            json: """
                {"totalItems":1,"results":[{"serverId":"F400","deviceName":"Living room Xbox","consoleType":"XboxSeriesX",
                 "powerState":"ConnectedStandby","outOfHomeWarning":false,"wirelessWarning":true,"isDevKit":false}]}
                """
        )

        let refreshes = CallCountStub()
        let client = makeClient(server: server, kind: .home, region: .homeRegion) { freshness in
            switch freshness {
            case .cachedAllowed: return "stale"
            case .refreshRequired:
                refreshes.record()

                return "fresh"
            }
        }

        // When
        let consoles = try await client.consoles()

        // Then
        let expectedConsole = Console(
            id: "F400",
            name: "Living room Xbox",
            consoleType: "XboxSeriesX",
            powerState: .connectedStandby,
            hasWirelessWarning: true
        )
        #expect(consoles == [expectedConsole])
        #expect(refreshes.callCount == 1)
        #expect(server.requests.last?.headers["Authorization"] == "Bearer fresh")
    }

    @Test
    func recentTitlesThenKeepLastPlayedDateAndEntitlement() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            "\(XboxEndpoint.cloudRegion.rawValue)/v2/titles/mru",
            json: """
                {"results":[{"titleId":"FORTNITE","details":{"productId":"9NBLGGH4RR2Z","hasEntitlement":false,"isFreeInStore":true,
                 "supportedInputTypes":["Controller","NativeTouch"]},"titleHistory":{"lastTimePlayed":"2026-09-20T10:09:31.1265541Z"}}]}
                """
        )
        let client = makeClient(server: server)

        // When
        let titles = try await client.recentTitles()

        // Then
        #expect(titles.count == 1)
        #expect(titles[0].isPlayable)
        #expect(titles[0].supportsTouch)
        #expect(titles[0].lastPlayed != nil)
        #expect(server.requests.first?.url.query == "mr=25")
    }

    @Test
    func titlesThenKeepTheTouchBundlesTheTitleCarries() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            "\(XboxEndpoint.cloudRegion.rawValue)/v2/titles",
            json: """
                {"results":[{"titleId":"FORTNITE","details":{"productId":"9NBLGGH4RR2Z","hasEntitlement":true,
                 "supportedTabs":[{"id":"7c1e2f-touch"}],"supportedInputTypes":["Controller","CustomTouchOverlay"]}},
                 {"titleId":"HALO","details":{"productId":"9PP5G1F0C2B6","hasEntitlement":true}}]}
                """
        )
        let client = makeClient(server: server)

        // When
        let titles = try await client.titles()

        // Then
        #expect(titles.map(\.touchBundleIDs) == [["7c1e2f-touch"], []])
    }

    @Test
    func titlesWhenATouchBundleHasNoIDThenSkipsOnlyThatBundle() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            "\(XboxEndpoint.cloudRegion.rawValue)/v2/titles",
            json: """
                {"results":[{"titleId":"FORTNITE","details":{"productId":"9NBLGGH4RR2Z","hasEntitlement":true,
                 "supportedTabs":[{"name":"Untitled"},{"id":"7c1e2f-touch"}]}}]}
                """
        )
        let client = makeClient(server: server)

        // When
        let titles = try await client.titles()

        // Then
        #expect(titles.map(\.touchBundleIDs) == [["7c1e2f-touch"]])
    }

    @Test
    func startSessionThenAsksForQualityTierThroughReportedOperatingSystem() async throws {
        // Given
        let server = XboxServerStub()
        let base = XboxEndpoint.cloudRegion.rawValue
        server.on(
            "\(base)/v5/sessions/cloud/play",
            json:
                #"{"sessionId":"ABC","sessionPath":"v5/sessions/cloud/ABC","state":"Provisioning"}"#
        )
        let client = makeClient(server: server)

        // When
        let session = try await client.startSession(
            titleID: "FORTNITE",
            quality: .highest,
            locale: "en-US"
        )

        // Then
        let request = try #require(server.requests.first)
        let body = try #require(
            request.body.flatMap { try JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        )
        #expect(session.url.absoluteString == "\(base)/v5/sessions/cloud/ABC")
        #expect(request.headers["X-MS-Device-Info"]?.contains(#""name":"tizen""#) == true)
        #expect((body["settings"] as? [String: Any])?["osName"] as? String == "tizen")
        #expect(body["titleId"] as? String == "FORTNITE")
    }
}

private extension GSSVClientTests {
    func makeClient(
        server: XboxServerStub,
        kind: GSSVClient.Kind = .cloud,
        region: XboxEndpoint = .cloudRegion,
        token: @escaping @Sendable (TokenFreshness) async throws -> String = { _ in "gs" }
    ) -> GSSVClient {
        .init(
            kind: kind,
            baseURL: URL(string: region.rawValue)!,
            httpClient: server.client,
            token: token
        )
    }
}
