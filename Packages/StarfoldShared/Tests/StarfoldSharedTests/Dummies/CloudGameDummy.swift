//
//  CloudGameDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension CloudGame {
    static var dummyZetaQuest: CloudGame {
        dummy(id: "ALPHA", name: "Zeta Quest", publisher: "Studio One")
    }

    static var dummyAlphaRacer: CloudGame {
        dummy(id: "BRAVO", name: "Alpha Racer", publisher: "Speed Co")
    }

    static var dummyStarfall: CloudGame {
        .init(
            title: .init(
                id: "STARFALL",
                productID: "9STARFALL",
                hasEntitlement: true,
                isFreeInStore: false,
                supportedInputTypes: ["Controller", "MKB", "NativeTouch"]
            ),
            product: .init(
                id: "9STARFALL",
                title: "Starfall",
                shortDescription: "A short tale.",
                description: "A long tale of the outer rim.",
                publisher: "Northwind",
                developer: "Northwind Studios",
                categories: ["Shooter", "Adventure"],
                posterImage: .dummyArtwork("poster"),
                heroImage: .dummyArtwork("hero"),
                titledHeroImage: .dummyArtwork("titled"),
                screenshots: [.dummyArtwork("one"), .dummyArtwork("two")],
                releaseDate: Date(timeIntervalSince1970: 1_761_955_200)
            )
        )
    }

    static func dummy(id: String, name: String, publisher: String) -> CloudGame {
        .init(
            title: .init(
                id: id,
                productID: "9\(id)",
                hasEntitlement: true,
                isFreeInStore: false,
                supportedInputTypes: ["Controller"]
            ),
            product: .init(id: "9\(id)", title: name, publisher: publisher)
        )
    }

    static func dummy(id: String, posterImage: URL?, tileImage: URL?) -> CloudGame {
        var game = dummy(id: id, name: id, publisher: "Studio One")
        game.product?.posterImage = posterImage
        game.product?.tileImage = tileImage
        return game
    }
}
