//
//  LiveCloudLibraryServiceTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

struct LiveCloudLibraryServiceTests {
    @Test
    func libraryThenListsPlayableTitlesNamedFromCatalog() async throws {
        // Given
        let (server, service) = try await makeService()
        server.installCloudLibrary()

        // When
        let library = try await service.library()

        // Then
        #expect(library.access == .gamePass)
        #expect(Set(library.games.map(\.id)) == ["ALPHA", "BRAVO"])
        #expect(Set(library.games.map(\.name)) == ["Alpha Racer", "Zeta Quest"])
        #expect(
            library.games.first { $0.id == "ALPHA" }?.product?.tileImage?.absoluteString
                == "https://img/a"
        )
        #expect(library.recentGames.map(\.id) == ["BRAVO"])
    }

    @Test
    func libraryThenCuratedListsMatchProductsIgnoringCaseAndUnplayableGames() async throws {
        // Given
        let (server, service) = try await makeService()
        server.installCloudLibrary()

        // When
        let library = try await service.library()

        // Then
        #expect(library.curated[.recentlyAdded]?.map(\.id) == ["ALPHA"])
    }

    @Test
    func libraryWhenAccountHasNoGamePassThenIsFreeToPlay() async throws {
        // Given
        let (server, service) = try await makeService(cloud: .freeToPlay)
        server.installCloudLibrary()

        // When
        let library = try await service.library()

        // Then
        #expect(library.access == .freeToPlay)
        #expect(!library.games.isEmpty)
    }

    @Test
    func libraryWhenGamePassOfferingHasOnlyFreeGamesThenIsFreeToPlay() async throws {
        // Given
        let (server, service) = try await makeService(cloud: .gamePass)
        server.on(
            .cloudTitles,
            json: """
                {"results":[{"titleId":"FORTNITE","details":{"productId":"BT5P2X999VH2","hasEntitlement":true,"isFreeInStore":false,"userSubscriptions":[]}}]}
                """
        )
        server.installCloudLibrary()

        // When
        let library = try await service.library()

        // Then
        #expect(library.access == .freeToPlay)
        #expect(library.games.map(\.id) == ["FORTNITE"])
    }

    @Test
    func libraryWhenAccountHasNoCloudGamingThenIsUnavailable() async throws {
        // Given
        let (_, service) = try await makeService(cloud: .unavailable)

        // When
        let library = try await service.library()

        // Then
        #expect(library.access == .unavailable)
        #expect(library.games.isEmpty)
    }
}

private extension LiveCloudLibraryServiceTests {
    func makeService(
        cloud: CloudEntitlement = .gamePass
    ) async throws -> (XboxServerStub, LiveCloudLibraryService) {
        let server = XboxServerStub()
        let account = try await server.signedInAccount(cloud: cloud)
        return (
            server, LiveCloudLibraryService(xboxAccount: account, httpClient: server.httpClient)
        )
    }
}
