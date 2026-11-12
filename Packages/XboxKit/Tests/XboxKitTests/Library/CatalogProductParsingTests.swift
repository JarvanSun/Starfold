//
//  CatalogProductParsingTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct CatalogProductParsingTests {
    @Test
    func initThenResolvesProtocolRelativeImageURLs() throws {
        // Given
        let fields = try #require(
            try JSONSerialization.jsonObject(
                with: Data(
                    #"{"ProductTitle":"Fortnite","StoreId":"9NBLGGH4RR2Z","XCloudTitleId":"FORTNITE","Image_Poster":{"URL":"//store-images.s-microsoft.com/image/abc","Caption":""},"Screenshots":[{"URL":"https://example.com/1.jpg"}]}"#
                        .utf8
                )
            ) as? [String: Any]
        )

        // When
        let product = try #require(CatalogProduct(storeKey: "9NBLGGH4RR2Z", fields: fields))

        // Then
        #expect(
            product.posterImage?.absoluteString == "https://store-images.s-microsoft.com/image/abc"
        )
        #expect(product.xCloudTitleID == "FORTNITE")
        #expect(product.screenshots.count == 1)
    }

    @Test
    func initWhenProductTitleIsMissingThenIsNil() {
        #expect(CatalogProduct(storeKey: "X", fields: ["StoreId": "X"]) == nil)
    }
}
