//
//  LocalizationCatalogTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StarfoldShared

struct LocalizationCatalogTests {
    @Test
    func repositoryThenFindsStarfoldSharedCatalog() {
        #expect(RepositoryCatalogs().paths.contains(starfoldKitCatalogPath))
    }

    @Test(arguments: RepositoryCatalogs().paths, ["en", "zh-Hans"])
    func catalogThenEveryKeyIsTranslated(path: String, language: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: RepositoryCatalogs().url(for: path))

        // When
        let missingKeys = catalog.keysMissingTranslation(for: language)

        // Then
        #expect(!catalog.isEmpty)
        #expect(missingKeys.isEmpty, "Missing \(language) in \(path): \(missingKeys)")
    }

    @Test(arguments: RepositoryCatalogs().paths)
    func catalogThenNoKeyIsStaleOrNeedsReview(path: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: RepositoryCatalogs().url(for: path))

        // When
        let keys = catalog.keysNeedingAttention()

        // Then
        #expect(keys.isEmpty, "Stale or needing review in \(path): \(keys)")
    }

    @Test(arguments: RepositoryCatalogs().paths)
    func catalogThenEveryKeyIsSemantic(path: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: RepositoryCatalogs().url(for: path))

        // When
        let keys = catalog.keysNotSemantic()

        // Then
        #expect(keys.isEmpty, "Not a semantic key in \(path): \(keys)")
    }

    @Test(arguments: RepositoryCatalogs().paths)
    func catalogThenEveryKeyHasComment(path: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: RepositoryCatalogs().url(for: path))

        // When
        let keys = catalog.keysWithoutComment()

        // Then
        #expect(keys.isEmpty, "No comment in \(path): \(keys)")
    }

    @Test
    func packageBundleThenShipsEveryCatalogLanguage() throws {
        // Given
        let catalog = try LocalizationCatalog(
            contentsOf: RepositoryCatalogs().url(for: starfoldKitCatalogPath)
        )
        let bundle = try packageBundle

        // When
        let missingLanguages = catalog.languages.filter {
            bundle.path(forResource: $0, ofType: "lproj") == nil
        }

        // Then
        #expect(!catalog.languages.isEmpty)
        #expect(missingLanguages.isEmpty, "Not in the package: \(missingLanguages.sorted())")
    }

    @Test(arguments: ["en", "zh-Hans"])
    func packageBundleThenCompiledTableHasNoEmptyValue(language: String) throws {
        // Given
        let url = try #require(
            try packageBundle.url(
                forResource: "Localizable",
                withExtension: "strings",
                subdirectory: "\(language).lproj"
            )
        )

        // When
        let table = try #require(
            try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
                as? [String: String]
        )

        // Then
        #expect(!table.isEmpty)
        #expect(table.filter { $0.value.isEmpty }.isEmpty, "Empty in \(language)")
    }
}

private extension LocalizationCatalogTests {
    var starfoldKitCatalogPath: String {
        "Packages/StarfoldShared/Sources/StarfoldShared/Resources/Localizable.xcstrings"
    }

    var packageBundle: Bundle {
        get throws {
            let url = Bundle(for: Preferences.self)
                .url(forResource: "StarfoldShared_StarfoldShared", withExtension: "bundle")
            return try #require(url.flatMap(Bundle.init(url:)))
        }
    }
}
