//
//  PreviewObjectPoolCloudGames.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation
import StarfoldShared
import XboxKit

// MARK: - CloudGames

extension PreviewObjectPool {
    static var favorites: FavoritesStore {
        preferences.favorites(for: profile.xuid)
    }

    static func libraryViewModel(
        state: LoadState = .loaded,
        games: [CloudGame] = PreviewObjectPool.cloudGames,
        access: CloudAccess = .gamePass
    ) -> LibraryViewModel {
        let library = LibraryViewModel(
            accountID: profile.xuid,
            service: cloudLibraryService(state: state, games: games, access: access),
            preferences: preferences,
            cache: libraryCache
        )

        Task { await library.refresh() }

        return library
    }

    static var cloudGames: [CloudGame] {
        [
            gamePassGame(
                .init(
                    id: "9NSTARFALL01",
                    title: "Starfall Vanguard: Chronicles of the Outer Rim – Deluxe Edition",
                    description:
                        "Lead the last fleet of the Outer Rim through a sweeping single-player campaign, then take your squad into twelve-player battles across shattered moons. The Deluxe Edition adds the Ironwake campaign, three hero skins and a soundtrack recorded with a full orchestra.",
                    publisher: "Northwind Interactive",
                    developer: "Northwind Studios",
                    categories: ["Shooter", "Action & adventure"],
                    releaseDate: Date(timeIntervalSince1970: 1_761_955_200)
                )
            ),
            freeToPlayGame(
                .init(
                    id: "9NKICKLINE02",
                    title: "Kickline",
                    description:
                        "Fast five-a-side football where every player is yours to control. Chain passes, pull off wall volleys and climb the seasonal ladder with friends.",
                    publisher: "Pitchside Games",
                    categories: ["Sports", "Multi-Player Online Battle Arena"]
                )
            ),
            gamePassGame(
                .init(
                    id: "9NLANTERN003",
                    title: "Lantern King",
                    shortDescription: "A pixel-art brawler about a king who lost his light.",
                    publisher: "Moth & Ember",
                    categories: ["Action & adventure", "Fighting"]
                )
            ),
            gamePassGame(
                .init(
                    id: "9NWELLSPRNG4",
                    title: "Wellspring",
                    description:
                        "Deep beneath a sleeping village, a small fox carries the last ember of the hearth. Explore a hand-drawn cavern that folds back on itself, learn new ways to move and rekindle the lanterns that keep the dark away.",
                    publisher: "Little Oak Games",
                    developer: "Little Oak Games",
                    categories: ["Action & adventure", "Platformer", "Role playing"],
                    releaseDate: Date(timeIntervalSince1970: 1_748_736_000)
                )
            ),
            gamePassGame(
                .init(
                    id: "9NGLASSDSRT5",
                    title: "Glass Desert",
                    description:
                        "Survive alone or with friends on a planet of singing dunes. Gather, build and trade across a living open world, then follow the storm-glass trail to the ruins of an empire that vanished overnight.",
                    publisher: "Saltwind Entertainment",
                    categories: ["Action & adventure", "Role playing", "Shooter"]
                )
            ),
            freeToPlayGame(
                .init(
                    id: "9NPETALARC06",
                    title: "Petal Arcana",
                    description:
                        "Four apprentices, one overgrown kingdom. Team up in online co-op, combine spells mid-flight and push deeper into a garden that rearranges itself every run.",
                    publisher: "Briar Lane Games",
                    categories: ["Action & adventure", "Role playing", "Other"]
                )
            ),
            gamePassGame(
                .init(
                    id: "9NDREAMSHRD7",
                    title: "Dreamshard",
                    description:
                        "Top-down roguelite action in a world built from forgotten dreams. Dodge storms of projectiles, swap between twin weapons and face the Sleeper alone or with up to three friends.",
                    publisher: "Kitebird",
                    categories: ["Action & adventure", "Strategy", "Role playing"]
                )
            ),
        ]
    }
}

// MARK: - Services

extension PreviewObjectPool {
    static func cloudLibraryService(
        state: LoadState,
        games: [CloudGame],
        access: CloudAccess
    ) -> PreviewCloudLibraryService {
        let library = CloudLibrary(
            games: games,
            recentGames: Array(games.prefix(4)),
            curated: [
                .recentlyAdded: Array(games.prefix(6)), .leavingSoon: Array(games.suffix(3)),
            ],
            access: access
        )
        return .init(reply: .init(state: state), content: library)
    }
}

// MARK: - Private

private extension PreviewObjectPool {
    static func gamePassGame(_ product: CatalogProduct) -> CloudGame {
        .init(
            title: .init(
                id: product.id,
                productID: product.id,
                hasEntitlement: true,
                isFreeInStore: false,
                supportedInputTypes: ["Controller", "MKB"]
            ),
            product: product
        )
    }

    static func freeToPlayGame(_ product: CatalogProduct) -> CloudGame {
        .init(
            title: .init(
                id: product.id,
                productID: product.id,
                hasEntitlement: false,
                isFreeInStore: true,
                supportedInputTypes: ["Controller"]
            ),
            product: product
        )
    }
}
#endif
