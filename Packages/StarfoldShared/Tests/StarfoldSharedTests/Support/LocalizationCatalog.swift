//
//  LocalizationCatalog.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct LocalizationCatalog: Decodable {
    private let strings: [String: Entry]

    var isEmpty: Bool {
        strings.isEmpty
    }

    var languages: Set<String> {
        Set(strings.values.flatMap { $0.languages })
    }

    init(contentsOf url: URL) throws {
        self = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
    }

    func keysMissingTranslation(for language: String) -> [String] {
        strings
            .filter { $0.value.shouldTranslate ?? true }
            .filter { $0.value.translatedValues(for: language).isEmpty }
            .map(\.key)
            .sorted()
    }

    func keysNeedingAttention() -> [String] {
        strings
            .filter { $0.value.needsAttention }
            .map(\.key)
            .sorted()
    }

    func keysNotSemantic() -> [String] {
        strings.keys
            .filter { $0.wholeMatch(of: semanticKey) == nil }
            .sorted()
    }

    func keysWithoutComment() -> [String] {
        strings
            .filter { !$0.value.hasComment }
            .map(\.key)
            .sorted()
    }
}

private extension LocalizationCatalog {
    struct Entry: Decodable {
        let comment: String?
        let extractionState: String?
        let shouldTranslate: Bool?
        let localizations: [String: Localization]?

        var hasComment: Bool {
            let text = comment?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return !text.isEmpty
        }

        var needsAttention: Bool {
            let isStale = extractionState == staleState
            let needsReview = localizations?.values.contains { $0.needsReview } ?? false
            return isStale || needsReview
        }

        var languages: [String] {
            localizations.map { Array($0.keys) } ?? []
        }

        private var staleState: String { "stale" }

        func translatedValues(for language: String) -> [String] {
            localizations?[language]?.values ?? []
        }
    }

    struct Localization: Decodable {
        let stringUnit: StringUnit?
        let variations: [String: [String: Variation]]?

        var units: [StringUnit] {
            let variationUnits = variations?.values.flatMap { $0.values.map(\.stringUnit) } ?? []
            return [stringUnit].compactMap { $0 } + variationUnits
        }

        var values: [String] {
            units.map(\.value).filter { !$0.isEmpty }
        }

        var needsReview: Bool {
            units.contains { $0.state == needsReviewState }
        }

        private var needsReviewState: String { "needs_review" }
    }

    struct Variation: Decodable {
        let stringUnit: StringUnit
    }

    struct StringUnit: Decodable {
        let state: String
        let value: String
    }

    var semanticKey: Regex<Substring> {
        /[a-z][A-Za-z0-9]*(?:\.[a-z][A-Za-z0-9]*)+(?: %(?:\d+\$)?(?:@|l{0,2}[diu]|l?f))*/
    }
}
