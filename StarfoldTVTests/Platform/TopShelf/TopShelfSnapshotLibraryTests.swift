//
//  TopShelfSnapshotLibraryTests.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StarfoldShared
import StreamKit
import Testing
import TopShelfKit
import XboxKit

@testable import Starfold

@MainActor
struct TopShelfSnapshotLibraryTests {
    @Test
    func initWhenAccountsAreRestoringThenLeavesTheTopShelfAlone() {
        // Given
        let app = makeApp()

        // When
        let snapshot = TopShelfSnapshot(app: app)

        // Then
        #expect(snapshot == nil)
    }

    @Test
    func initWhenSignedOutThenClearsTheTopShelf() async {
        // Given
        let app = makeApp()

        await app.restore()

        // When
        let snapshot = TopShelfSnapshot(app: app)

        // Then
        #expect(snapshot == TopShelfSnapshot())
    }

    @Test
    func initWhenThereAreMoreRecentGamesThanFitThenKeepsTheFirstInOrder() {
        // Given
        let recentGames = CloudGame.dummyRecentGames(count: 12)

        // When
        let snapshot = makeSnapshot(recentGames: recentGames)

        // Then
        let expectedIDs = recentGames.prefix(snapshot.rowItemLimit).map(\.id)
        #expect(snapshot.games.map(\.id) == expectedIDs)
    }

    @Test
    func initWhenConsoleHasActivityThenShowsTheGameLastSeenOnIt() {
        // Given
        let console = Console.dummyLivingRoom

        // When
        let snapshot = makeSnapshot(consoles: [console]) { _ in .dummyLastPlayedHere }

        // Then
        let expectedItem = TopShelfItem(
            id: console.id,
            title: console.name,
            imageURL: .dummyConsoleArtwork
        )
        #expect(snapshot.consoles == [expectedItem])
    }
}

private extension TopShelfSnapshotLibraryTests {
    func makeApp() -> AppViewModel {
        let preferences = Preferences(defaults: .dummyEmpty)
        let controllers = ControllerHub(routing: .direct)
        let picture = PictureCapabilities(
            canFit: true,
            canEnhance: false,
            shouldKeepLastFrame: false,
            isHDRDisplayAvailable: nil
        )
        return AppViewModel(
            accountService: AccountServiceStub(),
            cache: .init(directory: .temporaryDirectory.appending(path: UUID().uuidString)),
            settings: .init(preferences: preferences, controllers: controllers, picture: picture),
            streamDependencies: .init(
                preferences: preferences,
                controllers: controllers,
                picture: picture,
                overlays: .init(statisticsRows: [], controlsHideDelay: nil)
            )
        )
    }

    func makeSnapshot(
        recentGames: [CloudGame] = [],
        consoles: [Console] = [],
        activity: (Console) -> ConsoleActivity? = { _ in nil }
    ) -> TopShelfSnapshot {
        .init(recentGames: recentGames, consoles: consoles, activity: activity)
    }
}
