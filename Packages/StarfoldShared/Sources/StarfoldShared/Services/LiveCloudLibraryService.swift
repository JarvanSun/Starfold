//
//  LiveCloudLibraryService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit
import os

struct LiveCloudLibraryService: CloudLibraryService {
    private let xboxAccount: XboxAccount
    private let httpClient: HTTPClient
    private let log = Logger(category: .library)

    init(xboxAccount: XboxAccount, httpClient: HTTPClient) {
        self.xboxAccount = xboxAccount
        self.httpClient = httpClient
    }

    func library() async throws -> CloudLibrary {
        do {
            return try await loadLibrary(started: .now)
        } catch XboxAccountError.cloudGamingUnavailable {
            return .init(games: [], recentGames: [], curated: [:], access: .unavailable)
        }
    }

    private func loadLibrary(started: ContinuousClock.Instant) async throws -> CloudLibrary {
        let client = try await xboxAccount.cloudClient(httpClient: httpClient)
        log.info("Cloud signed in +\(self.elapsed(since: started), privacy: .public)")

        async let titlesFetch = client.titles()
        async let recentFetch = client.recentTitles()
        let titles = try await titlesFetch
        let recentTitles = (try? await recentFetch) ?? []
        log.info("Cloud titles fetched +\(self.elapsed(since: started), privacy: .public)")

        let catalog = await catalogClient()
        let games = await games(for: titles.filter(\.isPlayable), from: catalog)
        log.info("Cloud catalog fetched +\(self.elapsed(since: started), privacy: .public)")

        let gamesByID = Dictionary(
            games.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let isFreeToPlayOffering = await xboxAccount.isFreeToPlayCloud
        let library = CloudLibrary(
            games: games,
            recentGames: recentTitles.compactMap { gamesByID[$0.id] },
            curated: await curatedLists(of: games, from: catalog),
            access: access(for: titles, isFreeToPlayOffering: isFreeToPlayOffering)
        )
        log.info(
            "Cloud library loaded +\(self.elapsed(since: started), privacy: .public): \(games.count, privacy: .public) games, \(library.recentGames.count, privacy: .public) recent, access \(String(describing: library.access), privacy: .public)"
        )

        return library
    }

    private func elapsed(since start: ContinuousClock.Instant) -> String {
        (ContinuousClock.now - start).formatted(.units(allowed: [.milliseconds]))
    }

    private func catalogClient() async -> CatalogClient {
        let fallbackMarket = "US"
        let market = await xboxAccount.market ?? Locale.current.region?.identifier ?? fallbackMarket
        let fallbackLanguage = "en-US"
        let language = Locale.preferredLanguages.first ?? fallbackLanguage
        return .init(httpClient: httpClient, market: market, language: language)
    }

    private func games(for titles: [CloudTitle], from catalog: CatalogClient) async -> [CloudGame] {
        let products = await catalogProducts(for: titles, from: catalog)
        return titles.map { CloudGame(title: $0, product: products[$0.productID.uppercased()]) }
    }

    private func catalogProducts(
        for titles: [CloudTitle],
        from catalog: CatalogClient
    ) async -> [String: CatalogProduct] {
        do {
            return try await catalog.products(titles.map(\.productID))
        } catch {
            log.error("Catalog lookup failed: \(String(describing: error), privacy: .public)")

            return [:]
        }
    }

    private func curatedLists(
        of games: [CloudGame],
        from catalog: CatalogClient
    ) async -> [CatalogClient.List: [CloudGame]] {
        let gamesByProduct = Dictionary(
            games.map { ($0.title.productID.uppercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
        async let recentlyAdded = try? catalog.list(.recentlyAdded)
        async let leavingSoon = try? catalog.list(.leavingSoon)
        var lists: [CatalogClient.List: [CloudGame]] = [:]

        for curatedList in await [recentlyAdded, leavingSoon].compactMap({ $0 }) {
            if let list = CatalogClient.List(rawValue: curatedList.id) {
                lists[list] = curatedList.productIDs.compactMap { gamesByProduct[$0.uppercased()] }
            }
        }

        return lists
    }

    private func access(for titles: [CloudTitle], isFreeToPlayOffering: Bool) -> CloudAccess {
        let hasGamePassGames = titles.contains { $0.isPlayable && $0.isGrantedBySubscription }
        let isFreeToPlay = isFreeToPlayOffering || !hasGamePassGames
        return isFreeToPlay ? .freeToPlay : .gamePass
    }
}
