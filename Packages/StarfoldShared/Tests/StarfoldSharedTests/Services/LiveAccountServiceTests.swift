//
//  LiveAccountServiceTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct LiveAccountServiceTests {
    @Test
    func completeSignInThenRestoresTheAccountWithItsGamertag() async throws {
        // Given
        let (server, service) = makeService()
        server.installSignIn()
        let prompt = try await service.beginSignIn()

        // When
        let account = try await service.completeSignIn(prompt) {}

        // Then
        #expect(account.summary == .init(id: "2535", gamertag: "NovaPilot"))
        #expect(await service.restoreAccounts().map(\.summary) == [account.summary])
    }

    @Test
    func profileThenReadsTheSignedInAccountsProfile() async throws {
        // Given
        let (server, service) = makeService()
        server.installSignIn()
        let account = try await service.completeSignIn(try await service.beginSignIn()) {}

        // When
        let profile = try await service.profile(of: account)

        // Then
        #expect(profile.gamertag == "NovaPilot")
        #expect(profile.gamerscore == 5865)
    }

    @Test
    func signOutThenForgetsTheAccount() async throws {
        // Given
        let (server, service) = makeService()
        server.installSignIn()
        let account = try await service.completeSignIn(try await service.beginSignIn()) {}

        // When
        try service.signOut(account)

        // Then
        #expect(await service.restoreAccounts().isEmpty)
    }
}

private extension LiveAccountServiceTests {
    func makeService() -> (XboxServerStub, LiveAccountService) {
        let server = XboxServerStub()
        let service = LiveAccountService(
            store: .init(
                microsoftClientID: .dummyClientID,
                secrets: InMemorySecretStore(),
                http: server.client
            ),
            http: server.client,
            streamRuntime: StreamRuntime()
        )
        return (server, service)
    }
}
