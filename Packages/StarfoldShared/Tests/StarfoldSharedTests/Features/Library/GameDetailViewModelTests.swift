//
//  GameDetailViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

struct GameDetailViewModelTests {
    @Test
    func factsThenListsGenresDeveloperAndReleaseDate() {
        // Given / When
        let detail = makeDetail(game: .dummyStarfall)

        // Then
        let released = Date(timeIntervalSince1970: 1_761_955_200)
        #expect(detail.facts.map(\.kind) == [.genres, .developer, .released])
        #expect(
            detail.facts.map(\.value) == [
                ["Shooter", "Adventure"].formatted(.list(type: .and, width: .narrow)),
                "Northwind Studios",
                released.formatted(date: .long, time: .omitted),
            ]
        )
    }

    @Test
    func factsWhenCatalogKnowsNothingThenIsEmpty() {
        // Given / When
        let detail = makeDetail(game: .dummyZetaQuest)

        // Then
        #expect(detail.facts.isEmpty)
        #expect(detail.about == nil)
        #expect(detail.screenshots.isEmpty)
    }

    @Test
    func inputsThenListsControllerAndWhatTheTitleSupports() {
        // Given / When
        let everyInput = makeDetail(game: .dummyStarfall)
        let controllerOnly = makeDetail(game: .dummyZetaQuest)

        // Then
        #expect(everyInput.inputs == [.controller, .mouseAndKeyboard, .touch])
        #expect(controllerOnly.inputs == [.controller])
    }

    @Test
    func aboutWhenThereIsNoLongDescriptionThenIsTheShortOne() {
        // Given
        var game = CloudGame.dummyStarfall
        let long = makeDetail(game: game)
        game.product?.description = nil

        // When
        let short = makeDetail(game: game)

        // Then
        #expect(long.about == "A long tale of the outer rim.")
        #expect(short.about == "A short tale.")
    }

    @Test
    func heroArtworkThenPrefersThePlainHeroAndTitledHeroArtworkTheTitledOne() {
        // Given
        var game = CloudGame.dummyStarfall
        let both = makeDetail(game: game)
        game.product?.heroImage = nil
        game.product?.titledHeroImage = nil

        // When
        let posterOnly = makeDetail(game: game)

        // Then
        #expect(both.heroArtwork == .dummyArtwork("hero"))
        #expect(both.titledHeroArtwork == .dummyArtwork("titled"))
        #expect(posterOnly.heroArtwork == nil)
        #expect(posterOnly.titledHeroArtwork == .dummyArtwork("poster"))
    }

    @Test
    func publisherInitialThenIsTheFirstLetterOfThePublisher() {
        // Given / When
        let detail = makeDetail(game: .dummyStarfall)

        // Then
        #expect(detail.name == "Starfall")
        #expect(detail.publisher == "Northwind")
        #expect(detail.publisherInitial == "N")
    }

    @Test
    func toggleFavoriteThenTurnsTheFavoriteOnAndOff() {
        // Given
        let detail = makeDetail(game: .dummyStarfall)
        let actionBefore = detail.favoriteAction

        // When
        detail.toggleFavorite()
        let isFavoriteAfterFirstToggle = detail.isFavorite
        let actionAfterFirstToggle = detail.favoriteAction

        detail.toggleFavorite()

        // Then
        #expect(actionBefore == .add)
        #expect(isFavoriteAfterFirstToggle)
        #expect(actionAfterFirstToggle == .remove)
        #expect(!detail.isFavorite)
    }

    @Test
    func playThenAsksToPlay() {
        // Given
        var playCount = 0
        let detail = makeDetail(game: .dummyStarfall) { playCount += 1 }

        // When
        detail.play()

        // Then
        #expect(playCount == 1)
    }
}

private extension GameDetailViewModelTests {
    func makeDetail(game: CloudGame, onPlay: @escaping () -> Void = {}) -> GameDetailViewModel {
        .init(
            game: game,
            favoritesStore: AppHarness().preferences.makeFavoritesStore(for: "2535"),
            onPlay: onPlay
        )
    }
}
