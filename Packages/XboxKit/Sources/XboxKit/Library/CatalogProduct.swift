//
//  CatalogProduct.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct CatalogProduct: Codable, Sendable, Hashable, Identifiable {
    public var id: String
    public var title: String
    public var shortDescription: String?
    public var description: String?
    public var publisher: String?
    public var developer: String?
    public var categories: [String]
    public var tileImage: URL?
    public var posterImage: URL?
    public var heroImage: URL?
    public var titledHeroImage: URL?
    public var screenshots: [URL]
    var xCloudTitleID: String?
    public var releaseDate: Date?

    public init(
        id: String,
        title: String,
        shortDescription: String? = nil,
        description: String? = nil,
        publisher: String? = nil,
        developer: String? = nil,
        categories: [String] = [],
        tileImage: URL? = nil,
        posterImage: URL? = nil,
        heroImage: URL? = nil,
        titledHeroImage: URL? = nil,
        screenshots: [URL] = [],
        xCloudTitleID: String? = nil,
        releaseDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.shortDescription = shortDescription
        self.description = description
        self.publisher = publisher
        self.developer = developer
        self.categories = categories
        self.tileImage = tileImage
        self.posterImage = posterImage
        self.heroImage = heroImage
        self.titledHeroImage = titledHeroImage
        self.screenshots = screenshots
        self.xCloudTitleID = xCloudTitleID
        self.releaseDate = releaseDate
    }
}
