//
//  GSSVSessionTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct GSSVSessionTests {
    @Test
    func waitUntilProvisionedWhenReadyToConnectTwiceThenSendsTransferTokenOnce() async throws {
        // Given
        let server = XboxServerStub()
        server.on(stateURL, json: .dummySessionState("Provisioning"))
        server.on(stateURL, json: .dummySessionState("ReadyToConnect"))
        server.on(stateURL, json: .dummySessionState("ReadyToConnect"))
        server.on(stateURL, json: .dummySessionState("Provisioned"))
        server.on(connectURL, json: "{}")

        let fetches = CallCountStub()
        let session = makeSession(server: server)

        // When
        try await session.waitUntilProvisioned(
            transferToken: {
                fetches.record()

                return "lpt"
            },
            pollInterval: .zero
        )

        // Then
        let connects = server.requests(to: connectURL)
        let body = try #require(
            connects.first?.body.flatMap {
                try JSONSerialization.jsonObject(with: $0) as? [String: String]
            }
        )
        #expect(fetches.callCount == 1)
        #expect(connects.count == 1)
        #expect(body == ["userToken": "lpt"])
    }

    @Test
    func waitUntilProvisionedWhenQueuedThenReportsEstimateOnce() async throws {
        // Given
        let server = XboxServerStub()
        let waitTimeURL = "\(XboxEndpoint.cloudRegion.rawValue)/v1/waittime/FORTNITE"
        server.on(stateURL, json: .dummySessionState("WaitingForResources"))
        server.on(stateURL, json: .dummySessionState("WaitingForResources"))
        server.on(stateURL, json: .dummySessionState("Provisioned"))
        server.on(waitTimeURL, json: #"{"estimatedTotalWaitTimeInSeconds":180}"#)

        let reports = QueueEstimateStub()
        let session = makeSession(server: server)

        // When
        try await session.waitUntilProvisioned(
            transferToken: { "lpt" },
            pollInterval: .zero,
            onQueued: { reports.record($0) }
        )

        // Then
        #expect(reports.estimates == [.seconds(180)])
        #expect(server.requests(to: waitTimeURL).count == 1)
    }

    @Test
    func waitUntilProvisionedWhenSessionFailsThenThrowsHostCodeAndMessage() async {
        // Given
        let server = XboxServerStub()
        server.on(
            stateURL,
            json: .dummySessionState(
                "Failed",
                code: "WNSError",
                message: "WaitingForServerToRegister"
            )
        )
        let session = makeSession(server: server)

        // When / Then
        await #expect(
            throws: GSSVSessionError.failed(code: "WNSError", message: "WaitingForServerToRegister")
        ) {
            try await session.waitUntilProvisioned(transferToken: { "lpt" }, pollInterval: .zero)
        }
    }

    @Test
    func waitUntilProvisionedWhenTimeoutPassesThenThrowsTimedOut() async {
        // Given
        let server = XboxServerStub()
        server.on(stateURL, json: .dummySessionState("Provisioning"))
        let session = makeSession(server: server)

        // When / Then
        await #expect(throws: GSSVSessionError.timedOut("state")) {
            try await session.waitUntilProvisioned(
                transferToken: { "lpt" },
                pollInterval: .milliseconds(5),
                timeout: .milliseconds(30)
            )
        }
    }

    @Test
    func stopThenDeletesSessionOnHost() async {
        // Given
        let server = XboxServerStub()
        server.on(sessionURL, json: "")
        let session = makeSession(server: server)

        // When
        await session.stop()

        // Then
        #expect(server.requests(to: sessionURL).map(\.method) == ["DELETE"])
    }
}

private extension GSSVSessionTests {
    var sessionURL: String {
        "\(XboxEndpoint.cloudRegion.rawValue)/v5/sessions/cloud/ABC"
    }

    var stateURL: String {
        "\(sessionURL)/state"
    }

    var connectURL: String {
        "\(sessionURL)/connect"
    }

    func makeSession(server: XboxServerStub) -> GSSVSession {
        let client = GSSVClient(
            kind: .cloud,
            baseURL: URL(string: XboxEndpoint.cloudRegion.rawValue)!,
            http: server.client
        ) { _ in "gs" }
        return .init(client: client, url: URL(string: sessionURL)!, titleID: "FORTNITE")
    }
}
