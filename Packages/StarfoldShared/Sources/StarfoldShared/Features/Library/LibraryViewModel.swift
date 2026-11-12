//
//  LibraryViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Observation
import StreamKit
import XboxKit
import os

@Observable
public final class LibraryViewModel {
    private let accountID: String
    private let service: CloudLibraryService
    private let preferences: Preferences
    private let cache: LibraryCache
    let favorites: FavoritesStore

    public var searchText = ""
    public private(set) var games: [CloudGame] = []
    public private(set) var recentGames: [CloudGame] = []
    public private(set) var cloudAccess: CloudAccess = .unknown
    var onSignInRequired: () -> Void = {}
    var onPlay: (StreamTarget) -> Void = { _ in }
    private(set) var curated: [CatalogClient.List: [CloudGame]] = [:]
    private(set) var cloudState: LoadState = .idle
    private let log = Logger(category: .library)

    public var sort: GameSort {
        get { preferences.librarySort }
        set { preferences.librarySort = newValue }
    }

    public var sortChoices: [GameSort] {
        GameSort.allCases
    }

    public var isLoading: Bool {
        cloudState == .loading
    }

    public var canBrowse: Bool {
        cloudAccess != .unavailable
    }

    public var isLimitedToFreeToPlay: Bool {
        cloudAccess == .freeToPlay
    }

    public var isSearching: Bool {
        !searchQuery.isEmpty
    }

    public var hasNoSearchResults: Bool {
        isSearching && visibleGames.isEmpty
    }

    public var placeholder: LibraryPlaceholder? {
        switch (cloudState, games.isEmpty, cloudAccess) {
        case (.idle, true, _), (.loading, true, _): .loading
        case (.failed(let message), true, _): .failed(message)
        case (_, _, .unavailable): .unavailable
        case _ where hasNoSearchResults: .noResults
        default: nil
        }
    }

    public var shelves: [LibraryShelf] {
        LibraryShelf.allCases.filter { !games(on: $0).isEmpty }
    }

    public var gamesTitle: LocalizedStringResource {
        switch isSearching {
        case true: .init("library.games.results.title", bundle: .module)
        case false: .init("library.games.all.title", bundle: .module)
        }
    }

    public var visibleGames: [CloudGame] {
        games(matching: searchText)
    }

    public var searchResults: [CloudGame] {
        switch isSearching {
        case true: visibleGames
        case false: []
        }
    }

    var favoriteGames: [CloudGame] {
        games.filter { favorites.contains($0.id) }
    }

    public init(
        accountID: String,
        service: CloudLibraryService,
        preferences: Preferences,
        cache: LibraryCache
    ) {
        self.accountID = accountID
        self.service = service
        self.preferences = preferences
        self.cache = cache
        self.favorites = preferences.favorites(for: accountID)

        if let snapshot = cache.librarySnapshot(for: accountID) {
            restore(snapshot)
        }
    }

    public func refresh() async {
        cloudState = .loading

        do {
            let library = try await service.library()
            guard !Task.isCancelled else { return }

            show(library)

            saveSnapshot()
        } catch {
            recordFailure(error)
        }
    }

    public func play(_ game: CloudGame) {
        onPlay(.cloud(titleID: game.id, name: game.name))
    }

    public func detail(for game: CloudGame) -> GameDetailViewModel {
        .init(game: game, favorites: favorites, onPlay: { [weak self] in self?.play(game) })
    }

    public func games(on shelf: LibraryShelf) -> [CloudGame] {
        switch shelf {
        case .continuePlaying: recentGames
        case .favorites: favoriteGames
        case .recentlyAdded: curated[.recentlyAdded] ?? []
        case .leavingSoon: curated[.leavingSoon] ?? []
        }
    }

    public func recentGames(limit: Int) -> [CloudGame] {
        .init(recentGames.prefix(limit))
    }

    public func coverArtwork(limit: Int) -> [URL] {
        let candidates = recentGames + (curated[.recentlyAdded] ?? []) + games
        var seenURLs = Set<URL>()
        let uniqueCovers = candidates.compactMap(\.coverArtwork).filter {
            seenURLs.insert($0).inserted
        }
        return Array(uniqueCovers.prefix(limit))
    }

    public func game(id: String) -> CloudGame? {
        games.first { $0.id == id }
    }

    func games(matching search: String) -> [CloudGame] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        let matchingGames = games.filter { game($0, matches: query) }

        switch sort {
        case .name: return matchingGames
        case .recent: return sortedByRecentPlay(matchingGames)
        }
    }
}

// MARK: - Private

private extension LibraryViewModel {
    var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func show(_ library: CloudLibrary) {
        games = library.games.sorted { isNamed($0.name, before: $1.name) }
        recentGames = library.recentGames
        curated = library.curated
        cloudAccess = library.access
        cloudState = .loaded
    }

    func restore(_ snapshot: LibrarySnapshot) {
        let gamesByID = Dictionary(
            snapshot.games.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let curated = snapshot.curated.compactMap { key, ids in
            CatalogClient.List(rawValue: key).map { ($0, ids.compactMap { gamesByID[$0] }) }
        }

        show(
            .init(
                games: snapshot.games,
                recentGames: snapshot.recentIDs.compactMap { gamesByID[$0] },
                curated: .init(uniqueKeysWithValues: curated),
                access: CloudAccess(rawValue: snapshot.cloudAccess) ?? .unknown
            )
        )
    }

    func saveSnapshot() {
        let snapshot = LibrarySnapshot(
            games: games,
            recentIDs: recentGames.map(\.id),
            curated: .init(
                uniqueKeysWithValues: curated.map { ($0.key.rawValue, $0.value.map(\.id)) }
            ),
            cloudAccess: cloudAccess.rawValue
        )
        cache.save(snapshot, for: accountID)
    }

    func sortedByRecentPlay(_ games: [CloudGame]) -> [CloudGame] {
        let recentRank = Dictionary(
            recentGames.enumerated().map { ($1.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return games.sorted { lhs, rhs in
            switch (recentRank[lhs.id], recentRank[rhs.id]) {
            case (let left?, let right?): left < right
            case (_?, nil): true
            case (nil, _?): false
            case (nil, nil): isNamed(lhs.name, before: rhs.name)
            }
        }
    }

    func game(_ game: CloudGame, matches query: String) -> Bool {
        let matchesName = game.name.localizedStandardContains(query)
        let matchesPublisher = game.product?.publisher?.localizedStandardContains(query) ?? false
        return query.isEmpty || matchesName || matchesPublisher
    }

    func isNamed(_ name: String, before otherName: String) -> Bool {
        name.localizedStandardCompare(otherName) == .orderedAscending
    }

    func recordFailure(_ error: Error) {
        if case XboxAccountError.signInRequired = error {
            onSignInRequired()
        }

        log.error("Cloud library failed: \(String(describing: error), privacy: .public)")

        cloudState = .failed(error.localizedDescription)
    }
}
