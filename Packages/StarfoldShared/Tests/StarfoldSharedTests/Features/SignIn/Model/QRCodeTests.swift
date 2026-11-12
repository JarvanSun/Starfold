//
//  QRCodeTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Foundation
import Testing

@testable import StarfoldShared

struct QRCodeTests {
    @Test
    func imageThenIsASquareLargeEnoughToScan() throws {
        // Given
        let code = QRCode(url: .dummySignInPage)

        // When
        let image = try #require(code.image)

        // Then
        #expect(image.width == image.height)
        #expect(image.width >= 168)
    }
}
