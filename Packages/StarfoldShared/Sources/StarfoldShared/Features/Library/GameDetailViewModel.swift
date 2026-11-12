//
//  GameDetailViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Observation
import XboxKit

@Observable
public final class GameDetailViewModel {
    public let game: CloudGame
    private let favorites: FavoritesStore
    private let onPlay: () -> Void

    public var name: String {
        game.name
    }

    public var publisher: String? {
        game.product?.publisher
    }

    public var publisherInitial: String? {
        publisher.map { String($0.prefix(1)) }
    }

    public var about: String? {
        game.product?.description ?? game.product?.shortDescription
    }

    public var heroArtwork: URL? {
        game.heroArtwork
    }

    public var titledHeroArtwork: URL? {
        game.titledHeroArtwork
    }

    public var screenshots: [URL] {
        game.product?.screenshots ?? []
    }

    public var inputs: [GameInput] {
        [
            .controller,
            game.title.supportsMouseAndKeyboard ? .mouseAndKeyboard : nil,
            game.title.supportsTouch ? .touch : nil,
        ]
        .compactMap { $0 }
    }

    public var facts: [GameFact] {
        [genres, developer, released].compactMap { $0 }
    }

    public var isFavorite: Bool {
        favorites.contains(game.id)
    }

    public var favoriteAction: FavoriteAction {
        switch isFavorite {
        case true: .remove
        case false: .add
        }
    }

    init(game: CloudGame, favorites: FavoritesStore, onPlay: @escaping () -> Void) {
        self.game = game
        self.favorites = favorites
        self.onPlay = onPlay
    }

    public func play() {
        onPlay()
    }

    public func toggleFavorite() {
        favorites.toggle(game.id)
    }
}

private extension GameDetailViewModel {
    var genres: GameFact? {
        guard let categories = game.product?.categories, !categories.isEmpty else { return nil }

        return .init(kind: .genres, value: categories.formatted(.list(type: .and, width: .narrow)))
    }

    var developer: GameFact? {
        game.product?.developer.map { .init(kind: .developer, value: $0) }
    }

    var released: GameFact? {
        game.product?.releaseDate.map {
            .init(kind: .released, value: $0.formatted(date: .long, time: .omitted))
        }
    }
}
