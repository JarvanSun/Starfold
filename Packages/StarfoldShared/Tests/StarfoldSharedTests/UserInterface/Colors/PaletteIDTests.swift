//
//  PaletteIDTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StarfoldShared

struct PaletteIDTests {
    @Test(arguments: [nil, "graphite"] as [String?])
    func initWhenStoredValueIsMissingOrUnknownThenIsNebula(storedValue: String?) {
        #expect(PaletteID(storedValue: storedValue) == .nebula)
    }

    @Test
    func initWhenStoredValueIsKnownThenIsThatPalette() {
        #expect(PaletteID(storedValue: "aurora") == .aurora)
    }
}
