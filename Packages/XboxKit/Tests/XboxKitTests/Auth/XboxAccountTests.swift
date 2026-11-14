//
//  XboxAccountTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct XboxAccountTests {
    @Test
    func cloudStreamingTokenWhenGamePassIsDeniedThenFallsBackToFreeToPlayAndRemembersIt()
        async throws
    {
        // Given
        let server = XboxServerStub()
        let clock = ClockStub()
        server.on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        server.on(.securityTokenAuthorization, json: .dummyXboxTokenResponse(token: "gssv"))
        server.on(
            .cloudLogin,
            status: 403,
            json: #"{"code":"OfferingAccessDenied","statusCode":403}"#
        )
        server.on(.freeToPlayCloudLogin, json: .dummyStreamingLoginResponse(token: "f2p"))
        let (account, _) = try makeAccount(server: server, clock: clock)
        let token = try await account.cloudStreamingToken()
        clock.advance(5 * 3600)

        // When
        _ = try await account.cloudStreamingToken()

        // Then
        #expect(token.offering == .cloudFreeToPlay)
        #expect(await account.isFreeToPlayCloud)
        #expect(server.requests(to: .cloudLogin).count == 1)
        #expect(server.requests(to: .freeToPlayCloudLogin).count == 2)
    }

    @Test
    func homeStreamingTokenWhenCloseToExpiryThenFetchesAgain() async throws {
        // Given
        let server = XboxServerStub()
        let clock = ClockStub()
        server.on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        server.on(.securityTokenAuthorization, json: .dummyXboxTokenResponse(token: "gssv"))
        server.on(.homeLogin, json: .dummyStreamingLoginResponse(token: "home1"))
        server.on(.homeLogin, json: .dummyStreamingLoginResponse(token: "home2"))
        let (account, _) = try makeAccount(server: server, clock: clock)

        // When
        let first = try await account.homeStreamingToken().token

        clock.advance(3 * 3600)
        let reused = try await account.homeStreamingToken().token

        clock.advance(3600 - 30)
        let refetched = try await account.homeStreamingToken().token

        // Then
        #expect(first == "home1")
        #expect(reused == "home1")
        #expect(refetched == "home2")
    }

    @Test
    func webAuthorizationWhenMicrosoftTokenExpiredThenRefreshesOnceAndSavesRotatedToken()
        async throws
    {
        // Given
        let server = XboxServerStub()
        let clock = ClockStub()
        clock.advance(7200)

        server.on(
            .token,
            json: #"{"access_token":"new-access","refresh_token":"rotated","expires_in":3600}"#
        )
        server.on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        server.on(
            .securityTokenAuthorization,
            json: .dummyXboxTokenResponse(token: "web", gamertag: "NovaPilot", xuid: "2535")
        )
        let (account, secrets) = try makeAccount(server: server, clock: clock)

        // When
        async let first = account.webAuthorization()
        async let second = account.webAuthorization()
        _ = try await (first, second)

        // Then
        let savedSecret = try #require(try secrets.read("account.2535"))
        let saved = try JSONDecoder().decode(StoredAccount.self, from: savedSecret)
        let userAuthenticationBody = try #require(
            server.requests(to: .userAuthentication).first?.body
        )
        #expect(server.requests(to: .token).count == 1)
        #expect(saved.microsoftAccountToken.refreshToken == "rotated")
        #expect(String(decoding: userAuthenticationBody, as: UTF8.self).contains("d=new-access"))
    }

    @Test
    func webAuthorizationWhenRefreshTokenIsRejectedThenRequiresSignIn() async throws {
        // Given
        let server = XboxServerStub()
        let clock = ClockStub()
        clock.advance(7200)

        server.on(.token, status: 400, json: #"{"error":"invalid_grant"}"#)
        let (account, _) = try makeAccount(server: server, clock: clock)

        // When / Then
        await #expect(throws: XboxAccountError.signInRequired) {
            _ = try await account.webAuthorization()
        }
    }

    @Test
    func webAuthorizationWhenMicrosoftReportsARequestLoopThenKeepsTheSignIn() async throws {
        // Given
        let server = XboxServerStub()
        let clock = ClockStub()
        clock.advance(7200)

        server.on(
            .token,
            status: 400,
            json:
                #"{"error":"invalid_grant","error_description":"AADSTS50196: client request loop"}"#
        )
        let (account, _) = try makeAccount(server: server, clock: clock)

        // When / Then
        await #expect(throws: XboxHTTPError.self) {
            _ = try await account.webAuthorization()
        }
    }
}

private extension XboxAccountTests {
    func makeAccount(
        server: XboxServerStub,
        clock: ClockStub
    ) throws -> (XboxAccount, InMemorySecretStore) {
        let secrets = InMemorySecretStore()
        let store = AccountStore(
            microsoftClientID: .dummyClientID,
            secretStore: secrets,
            httpClient: server.httpClient,
            now: clock.nowProvider
        )
        let stored = StoredAccount(
            xuid: "2535",
            gamertag: "NovaPilot",
            microsoftAccountToken: .dummyExpiringInAnHour
        )
        try secrets.write(try JSONEncoder().encode(stored), for: "account.2535")
        return (try #require(store.restoreAccounts().first), secrets)
    }
}
