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
    public var searchText = ""

    var onSignInRequired: () -> Void = {}
    var onPlay: (StreamTarget) -> Void = { _ in }

    public private(set) var games: [CloudGame] = []
    public private(set) var recentGames: [CloudGame] = []
    public private(set) var cloudAccess: CloudAccess = .unknown

    let favoritesStore: FavoritesStore
    private(set) var curatedLists: [CatalogClient.List: [CloudGame]] = [:]
    private(set) var cloudState: LoadState = .idle

    private let accountID: String
    private let cloudLibraryService: CloudLibraryService
    private let preferences: Preferences
    private let libraryCache: LibraryCache
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

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
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

    public var sortedGames: [CloudGame] {
        games(matching: "")
    }

    public var searchResults: [CloudGame] {
        switch isSearching {
        case true: visibleGames
        case false: []
        }
    }

    var favoriteGames: [CloudGame] {
        games.filter { favoritesStore.contains($0.id) }
    }

    public init(
        accountID: String,
        cloudLibraryService: CloudLibraryService,
        preferences: Preferences,
        libraryCache: LibraryCache
    ) {
        self.accountID = accountID
        self.cloudLibraryService = cloudLibraryService
        self.preferences = preferences
        self.libraryCache = libraryCache
        self.favoritesStore = preferences.favorites(for: accountID)

        if let snapshot = libraryCache.librarySnapshot(for: accountID) {
            restore(snapshot)
        }
    }

    private func restore(_ snapshot: LibrarySnapshot) {
        let gamesByID = Dictionary(
            snapshot.games.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let curatedLists = snapshot.curated.compactMap { key, ids in
            CatalogClient.List(rawValue: key).map { ($0, ids.compactMap { gamesByID[$0] }) }
        }

        show(
            .init(
                games: snapshot.games,
                recentGames: snapshot.recentIDs.compactMap { gamesByID[$0] },
                curated: .init(uniqueKeysWithValues: curatedLists),
                access: CloudAccess(rawValue: snapshot.cloudAccess) ?? .unknown
            )
        )
    }

    private func show(_ library: CloudLibrary) {
        games = library.games.sorted { isNamed($0.name, before: $1.name) }
        recentGames = library.recentGames
        curatedLists = library.curated
        cloudAccess = library.access
        cloudState = .loaded
    }

    private func isNamed(_ name: String, before otherName: String) -> Bool {
        name.localizedStandardCompare(otherName) == .orderedAscending
    }

    public func refresh() async {
        cloudState = .loading

        do {
            let library = try await cloudLibraryService.library()
            guard !Task.isCancelled else { return }

            show(library)

            saveSnapshot()
        } catch {
            recordFailure(error)
        }
    }

    private func saveSnapshot() {
        let snapshot = LibrarySnapshot(
            games: games,
            recentIDs: recentGames.map(\.id),
            curated: .init(
                uniqueKeysWithValues: curatedLists.map { ($0.key.rawValue, $0.value.map(\.id)) }
            ),
            cloudAccess: cloudAccess.rawValue
        )
        libraryCache.save(snapshot, for: accountID)
    }

    private func recordFailure(_ error: Error) {
        if case XboxAccountError.signInRequired = error {
            onSignInRequired()
        }

        log.error("Cloud library failed: \(String(describing: error), privacy: .public)")

        cloudState = .failed(error.localizedDescription)
    }

    public func play(_ game: CloudGame) {
        onPlay(.cloud(titleID: game.id, name: game.name))
    }

    public func detail(for game: CloudGame) -> GameDetailViewModel {
        .init(
            game: game,
            favoritesStore: favoritesStore,
            onPlay: { [weak self] in self?.play(game) }
        )
    }

    public func games(on shelf: LibraryShelf) -> [CloudGame] {
        switch shelf {
        case .continuePlaying: recentGames
        case .favorites: favoriteGames
        case .recentlyAdded: curatedLists[.recentlyAdded] ?? []
        case .leavingSoon: curatedLists[.leavingSoon] ?? []
        }
    }

    public func recentGames(limit: Int) -> [CloudGame] {
        .init(recentGames.prefix(limit))
    }

    public func coverArtwork(limit: Int) -> [URL] {
        let candidates = recentGames + (curatedLists[.recentlyAdded] ?? []) + games
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
        let matchingGames = games.filter { $0.matches(query) }

        switch sort {
        case .name: return matchingGames
        case .recent: return sortedByRecentPlay(matchingGames)
        }
    }

    private func sortedByRecentPlay(_ games: [CloudGame]) -> [CloudGame] {
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
}

private extension CloudGame {
    func matches(_ query: String) -> Bool {
        let matchesName = name.localizedStandardContains(query)
        let matchesPublisher = product?.publisher?.localizedStandardContains(query) ?? false
        return query.isEmpty || matchesName || matchesPublisher
    }
}
