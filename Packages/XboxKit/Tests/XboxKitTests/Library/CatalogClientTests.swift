//
//  CatalogClientTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct CatalogClientTests {
    @Test
    func listThenSkipsMetadataEntryAndKeepsProductOrder() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .curatedList,
            json: """
                [{"siglId":"06323672","title":"Recently added","requiresShuffling":"False"},{"id":"9AAA"},{"id":"9BBB"}]
                """
        )
        let client = makeClient(server: server)

        // When
        let list = try await client.list(.recentlyAdded)

        // Then
        #expect(list.title == "Recently added")
        #expect(list.productIDs == ["9AAA", "9BBB"])
    }

    @Test
    func productsWhenMoreThanOneHundredThenSendsBatches() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            .catalogProducts,
            json: #"{"Products":{"X":{"ProductTitle":"Game","StoreId":"X"}}}"#
        )
        let client = makeClient(server: server)

        // When
        _ = try await client.products((0..<250).map { "ID\($0)" })

        // Then
        let batchSizes = try server.requests(to: .catalogProducts).map { request in
            let body = try #require(
                request.body.flatMap {
                    try JSONSerialization.jsonObject(with: $0) as? [String: [String]]
                }
            )
            return body["Products"]?.count ?? 0
        }
        #expect(batchSizes.sorted() == [50, 100, 100])
    }

    @Test
    func productsWhenServiceAnswersServerErrorThenRetriesAndReturnsNames() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.catalogProducts, status: 500, json: #"{"status":500}"#)
        server.on(.catalogProducts, json: .dummyFortniteProducts)
        let client = makeClient(server: server, market: "DE")

        // When
        let products = try await client.products(["bt5p2x999vh2"])

        // Then
        #expect(products["BT5P2X999VH2"]?.title == "Fortnite")
        #expect(server.requests(to: .catalogProducts).count == 2)
    }

    @Test
    func productsWhenBatchKeepsFailingThenSplitsItAndReturnsGoodHalf() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.catalogProducts, status: 500, json: "{}")
        server.on(.catalogProducts, status: 500, json: "{}")
        server.on(.catalogProducts, json: .dummyFortniteProducts)
        let client = makeClient(server: server, market: "DE")

        // When
        let products = try await client.products(["BT5P2X999VH2", "9BADBADBAD00"])

        // Then
        #expect(products["BT5P2X999VH2"]?.title == "Fortnite")
    }

    @Test
    func productsWhenIDsAreEmptyThenSendsNothing() async throws {
        // Given
        let server = XboxServerStub()
        let client = makeClient(server: server)

        // When
        let products = try await client.products(["", ""])

        // Then
        #expect(products.isEmpty)
        #expect(server.requests.isEmpty)
    }
}

private extension CatalogClientTests {
    func makeClient(server: XboxServerStub, market: String = "US") -> CatalogClient {
        .init(httpClient: server.client, market: market, language: "en-US")
    }
}
