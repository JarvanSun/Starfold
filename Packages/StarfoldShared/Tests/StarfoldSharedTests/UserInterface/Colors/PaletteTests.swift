//
//  PaletteTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Testing

@testable import StarfoldShared

struct PaletteTests {
    @Test(arguments: PaletteID.allCases)
    func primaryLabelThenReadsAtLeastFourAndAHalfToOneOnEveryFillColor(id: PaletteID) {
        // Given
        let palette = Palette(id)

        // When
        let ratios = palette.primary.map { palette.primaryLabel.contrast(with: $0) }

        // Then
        #expect(ratios.allSatisfy { $0 >= 4.5 }, "\(id): \(ratios)")
    }
}
