//
//  TouchColorTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchColorTests {
    @Test(
        arguments: [
            ("#FFF", TouchColor.rgba(red: 1, green: 1, blue: 1, alpha: 1)),
            ("#0000", .rgba(red: 0, green: 0, blue: 0, alpha: 0)),
            ("#FF0000", .rgba(red: 1, green: 0, blue: 0, alpha: 1)),
            ("#00ff0080", .rgba(red: 0, green: 1, blue: 0, alpha: 128 / 255)),
            ("colors/system_accentPrimary", .palette("system_accentPrimary")),
            ("#12345", .unsupported("#12345")),
            ("#GGGGGG", .unsupported("#GGGGGG")),
            ("red", .unsupported("red")),
        ]
    )
    func initThenParsesHexAndPaletteColors(text: String, expected: TouchColor) {
        #expect(TouchColor(text: text) == expected)
    }
}
