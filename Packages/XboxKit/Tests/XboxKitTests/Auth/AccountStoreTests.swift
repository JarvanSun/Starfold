//
//  AccountStoreTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct AccountStoreTests {
    @Test
    func completeSignInWhenAuthorizationIsPendingOnceThenSavesAccount() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse())
        server.on(.token, status: 400, json: #"{"error":"authorization_pending"}"#)
        server.on(
            .token,
            json: #"{"access_token":"msa-access","refresh_token":"msa-refresh","expires_in":3600}"#
        )
        server.on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        server.on(
            .securityTokenAuthorization,
            json: .dummyXboxTokenResponse(token: "web", gamertag: "NovaPilot", xuid: "2535")
        )
        let store = makeStore(server: server)
        let prompt = try await store.beginSignIn()

        // When
        let account = try await store.completeSignIn(prompt)

        // Then
        #expect(prompt.userCode == "ABCD1234")
        #expect(account.xuid == "2535")
        #expect(await account.gamertag == "NovaPilot")
        #expect(server.requests(to: .token).count == 2)
        #expect(store.restoreAccounts().map(\.xuid) == ["2535"])
    }

    @Test
    func completeSignInWhenDeviceCodeExpiredThenThrowsExpired() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.deviceCode, json: .dummyDeviceCodeResponse(userCode: "A"))
        server.on(.token, status: 400, json: #"{"error":"expired_token"}"#)
        let store = makeStore(server: server)
        let prompt = try await store.beginSignIn()

        // When / Then
        await #expect(throws: DeviceCodeError.expired) {
            _ = try await store.completeSignIn(prompt)
        }
    }
}

private extension AccountStoreTests {
    func makeStore(server: XboxServerStub) -> AccountStore {
        .init(
            microsoftClientID: .dummyClientID,
            secrets: InMemorySecretStore(),
            http: server.client
        )
    }
}
