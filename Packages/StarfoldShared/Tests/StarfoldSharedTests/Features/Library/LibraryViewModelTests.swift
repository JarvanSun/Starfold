//
//  LibraryViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct LibraryViewModelTests {
    @Test
    func refreshThenListsGamesByNameWithRecentAndCuratedRows() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        // When
        await library.refresh()

        // Then
        #expect(library.cloudState == .loaded)
        #expect(library.cloudAccess == .gamePass)
        #expect(library.games.map(\.name) == ["Alpha Racer", "Zeta Quest"])
        #expect(library.recentGames.map(\.id) == ["BRAVO"])
        #expect(library.curated[.recentlyAdded]?.map(\.id) == ["ALPHA"])
    }

    @Test
    func refreshWhileServiceIsAnsweringThenIsLoading() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.isHanging = true

        // When
        let refreshing = Task { await library.refresh() }
        defer { refreshing.cancel() }

        // Then
        #expect(await Eventually().holds { library.cloudState == .loading })
    }

    @Test
    func refreshWhenServiceFailsThenStateIsFailedAndGamesStay() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        service.content = .failure(URLError(.notConnectedToInternet))

        // When
        await library.refresh()

        // Then
        #expect(isFailed(library.cloudState), "\(library.cloudState)")
        #expect(library.games.count == 2)
    }

    @Test
    func refreshWhenSignInIsRequiredThenAsksForIt() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .failure(XboxAccountError.signInRequired)
        var isSignInRequested = false
        library.onSignInRequired = { isSignInRequested = true }

        // When
        await library.refresh()

        // Then
        #expect(isSignInRequested)
    }

    @Test
    func initWhenRelaunchedWithoutNetworkThenShowsSavedLibrary() async {
        // Given
        let (harness, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        let offline = CloudLibraryServiceStub()
        offline.isHanging = true

        // When
        let cached = AppHarness(relaunching: harness).library(for: "2535", service: offline)

        // Then
        #expect(cached.games.map(\.id) == library.games.map(\.id))
        #expect(cached.recentGames.map(\.id) == library.recentGames.map(\.id))
        #expect(cached.curated[.recentlyAdded]?.map(\.id) == ["ALPHA"])
        #expect(cached.cloudAccess == .gamePass)
        #expect(cached.cloudState == .loaded)
    }

    @Test
    func initWhenAnotherAccountSavedALibraryThenStartsEmpty() async {
        // Given
        let (harness, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        // When
        let otherLibrary = harness.library(for: "9999", service: CloudLibraryServiceStub())

        // Then
        #expect(otherLibrary.games.isEmpty)
    }

    @Test(arguments: [("  zeta ", ["ALPHA"]), ("speed co", ["BRAVO"]), ("nothing", [])])
    func gamesWhenSearchingThenMatchesNameOrPublisherIgnoringCaseAndSpaces(
        search: String,
        expectedIDs: [String]
    ) async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        // When
        let games = library.games(matching: search)

        // Then
        #expect(games.map(\.id) == expectedIDs)
    }

    @Test
    func gamesWhenSortedByRecentThenPutsPlayedGamesFirstAndTheRestByName() async {
        // Given
        let (_, service, library) = makeLibrary()
        var content = CloudLibrary.dummyGamePass
        content.recentGames = [.dummyZetaQuest]
        service.content = .success(content)

        await library.refresh()

        // When
        library.sort = .recent
        let byRecent = library.games(matching: "")

        library.sort = .name
        let byName = library.games(matching: "")

        // Then
        #expect(byRecent.map(\.id) == ["ALPHA", "BRAVO"])
        #expect(byName.map(\.id) == ["BRAVO", "ALPHA"])
    }

    @Test
    func gamesWhenRecentListRepeatsGameThenStillSorts() async {
        // Given
        let (_, service, library) = makeLibrary()
        var content = CloudLibrary.dummyGamePass
        content.recentGames = [.dummyZetaQuest, .dummyAlphaRacer, .dummyZetaQuest]
        service.content = .success(content)

        await library.refresh()

        library.sort = .recent

        // When
        let games = library.games(matching: "")

        // Then
        #expect(games.map(\.id) == ["ALPHA", "BRAVO"])
    }

    @Test
    func coverArtworkThenTakesRecentThenRecentlyAddedThenAllGamesOnceEach() async {
        // Given
        let played = CloudGame.dummy(id: "PLAYED", posterImage: .dummyArtwork("p"), tileImage: nil)
        let added = CloudGame.dummy(id: "ADDED", posterImage: nil, tileImage: .dummyArtwork("a"))
        let bare = CloudGame.dummy(id: "BARE", posterImage: nil, tileImage: nil)
        let last = CloudGame.dummy(id: "LAST", posterImage: .dummyArtwork("l"), tileImage: nil)
        let other = CloudGame.dummy(id: "OTHER", posterImage: .dummyArtwork("o"), tileImage: nil)
        let (_, service, library) = makeLibrary()
        service.content = .success(
            .init(
                games: [played, added, bare, last, other],
                recentGames: [played],
                curated: [.recentlyAdded: [added, played]],
                access: .gamePass
            )
        )

        await library.refresh()

        // When
        let covers = library.coverArtwork(limit: 3)

        // Then
        #expect(covers == [.dummyArtwork("p"), .dummyArtwork("a"), .dummyArtwork("l")])
    }

    @Test
    func coverArtworkWhenNoGameHasArtworkThenIsEmpty() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        // When / Then
        #expect(library.coverArtwork(limit: 3).isEmpty)
    }

    @Test
    func placeholderWhenNothingIsLoadedYetThenIsLoading() {
        // Given / When
        let (_, _, library) = makeLibrary()

        // Then
        #expect(library.placeholder == .loading)
    }

    @Test
    func placeholderWhenFirstLoadFailsThenIsFailed() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .failure(URLError(.notConnectedToInternet))

        // When
        await library.refresh()

        // Then
        #expect(
            library.placeholder == .failed(URLError(.notConnectedToInternet).localizedDescription)
        )
    }

    @Test
    func placeholderWhenAccountHasNoCloudGamingThenIsUnavailable() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyEmpty)

        // When
        await library.refresh()

        // Then
        #expect(library.placeholder == .unavailable)
        #expect(!library.canBrowse)
    }

    @Test(arguments: [("", nil), ("zeta", nil), ("nothing", LibraryPlaceholder.noResults)])
    func placeholderWhenGamesAreLoadedThenFollowsTheSearch(
        searchText: String,
        expected: LibraryPlaceholder?
    ) async {
        // Given
        let library = await makeLoadedLibrary()

        // When
        library.searchText = searchText

        // Then
        #expect(library.placeholder == expected)
    }

    @Test
    func placeholderWhenRefreshFailsWithGamesOnScreenThenIsNil() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        service.content = .failure(URLError(.notConnectedToInternet))

        // When
        await library.refresh()

        // Then
        #expect(library.placeholder == nil)
    }

    @Test
    func shelvesThenListsOnlyShelvesThatHaveGamesInOrder() async {
        // Given
        let library = await makeLoadedLibrary()

        // When
        library.favorites.toggle("ALPHA")

        // Then
        #expect(library.shelves == [.continuePlaying, .favorites, .recentlyAdded])
        #expect(library.games(on: .continuePlaying).map(\.id) == ["BRAVO"])
        #expect(library.games(on: .favorites).map(\.id) == ["ALPHA"])
        #expect(library.games(on: .recentlyAdded).map(\.id) == ["ALPHA"])
        #expect(library.games(on: .leavingSoon).isEmpty)
    }

    @Test
    func visibleGamesWhenNotSearchingThenIsEveryGameAndThereAreNoResults() async {
        // Given / When
        let library = await makeLoadedLibrary()

        // Then
        #expect(!library.isSearching)
        #expect(library.visibleGames.map(\.id) == ["BRAVO", "ALPHA"])
        #expect(library.searchResults.isEmpty)
        #expect(library.gamesTitle.key == "library.games.all.title")
    }

    @Test
    func visibleGamesWhenSearchingThenIsTheMatchingGames() async {
        // Given
        let library = await makeLoadedLibrary()

        // When
        library.searchText = " zeta "

        // Then
        #expect(library.isSearching)
        #expect(library.visibleGames.map(\.id) == ["ALPHA"])
        #expect(library.searchResults.map(\.id) == ["ALPHA"])
        #expect(library.gamesTitle.key == "library.games.results.title")
    }

    @Test
    func isSearchingWhenSearchTextIsOnlySpacesThenIsFalse() async {
        // Given
        let library = await makeLoadedLibrary()

        // When
        library.searchText = "   "

        // Then
        #expect(!library.isSearching)
    }

    @Test
    func recentGamesWhenLimitedThenTakesTheFirstOnes() async {
        // Given
        let (_, service, library) = makeLibrary()
        var content = CloudLibrary.dummyGamePass
        content.recentGames = [.dummyZetaQuest, .dummyAlphaRacer]
        service.content = .success(content)

        // When
        await library.refresh()

        // Then
        #expect(library.recentGames(limit: 1).map(\.id) == ["ALPHA"])
        #expect(library.recentGames(limit: 5).map(\.id) == ["ALPHA", "BRAVO"])
    }

    @Test
    func isLimitedToFreeToPlayWhenAccountHasNoGamePassThenIsTrue() async {
        // Given
        let (_, service, library) = makeLibrary()
        var content = CloudLibrary.dummyGamePass
        content.access = .freeToPlay
        service.content = .success(content)

        // When
        await library.refresh()

        // Then
        #expect(library.isLimitedToFreeToPlay)
        #expect(library.canBrowse)
    }

    @Test
    func playThenAsksForTheCloudGame() {
        // Given
        let (_, _, library) = makeLibrary()
        var requested: [StreamTarget] = []
        library.onPlay = { requested.append($0) }

        // When
        library.play(.dummyZetaQuest)

        // Then
        #expect(requested == [.cloud(titleID: "ALPHA", name: "Zeta Quest")])
    }

    @Test
    func detailThenPlaysAndFavoritesThroughTheLibrary() async {
        // Given
        let library = await makeLoadedLibrary()
        var requested: [StreamTarget] = []
        library.onPlay = { requested.append($0) }
        let detail = library.detail(for: .dummyZetaQuest)

        // When
        detail.play()
        detail.toggleFavorite()

        // Then
        #expect(requested == [.cloud(titleID: "ALPHA", name: "Zeta Quest")])
        #expect(library.favoriteGames.map(\.id) == ["ALPHA"])
    }

    @Test
    func sortWhenNothingIsStoredThenIsByName() {
        // Given / When
        let (_, _, library) = makeLibrary()

        // Then
        #expect(library.sort == .name)
    }

    @Test
    func sortWhenChangedThenEveryAccountKeepsItAfterRelaunch() {
        // Given
        let (harness, _, library) = makeLibrary()
        let relaunched = AppHarness(relaunching: harness)

        // When
        library.sort = .recent

        // Then
        #expect(relaunched.library(for: "9999", service: CloudLibraryServiceStub()).sort == .recent)
    }

    @Test
    func favoriteGamesWhenGameIsToggledThenListsIt() async {
        // Given
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        // When
        library.favorites.toggle("ALPHA")

        // Then
        #expect(library.favoriteGames.map(\.id) == ["ALPHA"])
    }
}

private extension LibraryViewModelTests {
    func makeLibrary() -> (AppHarness, CloudLibraryServiceStub, LibraryViewModel) {
        let harness = AppHarness()
        let service = CloudLibraryServiceStub()
        return (harness, service, harness.library(for: "2535", service: service))
    }

    func makeLoadedLibrary() async -> LibraryViewModel {
        let (_, service, library) = makeLibrary()
        service.content = .success(.dummyGamePass)

        await library.refresh()

        return library
    }

    func isFailed(_ state: LoadState) -> Bool {
        switch state {
        case .failed: true
        case .idle, .loading, .loaded: false
        }
    }
}
