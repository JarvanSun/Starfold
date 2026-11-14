//
//  DeviceCodeFlowTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct DeviceCodeFlowTests {
    @Test
    func startWhenServerSendsNoCompleteURLThenVerificationURLCarriesCode() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        let flow = makeFlow(server: server)

        // When
        let prompt = try await flow.start()

        // Then
        #expect(
            prompt.verificationURLComplete.absoluteString
                == "https://www.microsoft.com/link?otc=ABCD1234"
        )
    }

    @Test
    func startWhenConnectionIsLostThenAsksAgain() async throws {
        // Given
        let server = XboxServerStub()
        server.fail(.deviceCode, with: .networkConnectionLost)
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        let flow = makeFlow(server: server)

        // When
        let prompt = try await flow.start()

        // Then
        #expect(prompt.userCode == "ABCD1234")
        #expect(server.requests(to: .deviceCode).count == 2)
    }

    @Test
    func waitForTokenWhenConnectionIsLostThenPollsAgainAtOnce() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        server.fail(.token, with: .networkConnectionLost)
        server.on(.token, json: #"{"access_token":"msa-access","expires_in":3600}"#)
        let sleeps = CallCountStub()
        let flow = makeFlow(server: server, sleeps: sleeps)
        let prompt = try await flow.start()

        // When
        let token = try await flow.waitForToken(prompt)

        // Then
        #expect(token.accessToken == "msa-access")
        #expect(server.requests(to: .token).count == 2)
        #expect(sleeps.callCount == 1)
    }

    @Test
    func waitForTokenWhenConnectionStaysLostThenWaitsBeforePollingAgain() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        server.fail(.token, with: .notConnectedToInternet)
        server.fail(.token, with: .notConnectedToInternet)
        server.on(.token, json: #"{"access_token":"msa-access","expires_in":3600}"#)
        let sleeps = CallCountStub()
        let flow = makeFlow(server: server, sleeps: sleeps)
        let prompt = try await flow.start()

        // When
        let token = try await flow.waitForToken(prompt)

        // Then
        #expect(token.accessToken == "msa-access")
        #expect(server.requests(to: .token).count == 3)
        #expect(sleeps.callCount == 2)
    }
}

private extension DeviceCodeFlowTests {
    func makeFlow(server: XboxServerStub, sleeps: CallCountStub = .init()) -> DeviceCodeFlow {
        .init(
            configuration: MicrosoftIdentity(clientID: .dummyClientID).deviceCodeConfiguration,
            httpClient: server.httpClient,
            sleep: { _ in sleeps.record() }
        )
    }
}
