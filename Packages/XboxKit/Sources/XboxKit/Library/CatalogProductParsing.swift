//
//  CatalogProductParsing.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension CatalogProduct {
    init?(storeKey: String, fields: [String: Any]) {
        let entry = StoreEntry(fields: fields)
        guard let title = entry.string("ProductTitle") else {
            return nil
        }

        self.init(
            id: entry.string("StoreId") ?? storeKey,
            title: title,
            shortDescription: entry.string("ProductDescriptionShort"),
            description: entry.string("ProductDescription"),
            publisher: entry.string("PublisherName"),
            developer: entry.string("DeveloperName"),
            categories: entry.categories,
            tileImage: entry.imageURL("Image_Tile"),
            posterImage: entry.imageURL("Image_Poster"),
            heroImage: entry.imageURL("Image_Hero"),
            titledHeroImage: entry.imageURL("Image_TitledHero"),
            screenshots: entry.screenshots,
            xCloudTitleID: entry.string("XCloudTitleId"),
            releaseDate: entry.string("OriginalReleaseDate").flatMap(XboxDateParser().date(from:))
        )
    }
}

private struct StoreEntry {
    let fields: [String: Any]

    var categories: [String] {
        (fields["LocalizedCategories"] as? [String]) ?? (fields["Categories"] as? [String]) ?? []
    }

    var screenshots: [URL] {
        entries("Screenshots").compactMap { absoluteURL($0["URL"]) }
    }

    private func entries(_ key: String) -> [[String: Any]] {
        fields[key] as? [[String: Any]] ?? []
    }

    private func absoluteURL(_ field: Any?) -> URL? {
        guard var text = field as? String, !text.isEmpty else {
            return nil
        }

        if text.hasPrefix("//") {
            text = "https:" + text
        }

        return URL(string: text)
    }

    func string(_ key: String) -> String? {
        fields[key] as? String
    }

    func imageURL(_ key: String) -> URL? {
        (fields[key] as? [String: Any]).flatMap { absoluteURL($0["URL"]) }
    }
}
