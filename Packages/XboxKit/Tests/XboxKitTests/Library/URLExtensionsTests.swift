//
//  URLExtensionsTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct URLExtensionsTests {
    @Test(
        arguments: [
            (
                "http://images-eds.xboxlive.com/image?url=abc&format=png",
                "https://images-eds-ssl.xboxlive.com/image?url=abc&format=png"
            ),
            (
                "http://store-images.s-microsoft.com/tile",
                "https://store-images.s-microsoft.com/tile"
            ),
            ("https://example.com/a.png", "https://example.com/a.png"),
        ]
    )
    func initUpgradingXboxImageToHTTPSThenUsesHTTPSHost(text: String, expected: String) {
        #expect(URL(upgradingXboxImageToHTTPS: text)?.absoluteString == expected)
    }
}
