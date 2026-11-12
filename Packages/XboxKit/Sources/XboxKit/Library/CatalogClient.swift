//
//  CatalogClient.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public struct CatalogClient: Sendable {
    public enum List: String, Sendable, CaseIterable {
        case recentlyAdded = "06323672-b8c8-43cc-b0de-32d5a9834749"
        case allGamePass = "af206485-e87d-4624-9007-cb7f6d0cc42e"
        case leavingSoon = "31ff2361-2772-4622-849b-f4f1abb4ad1b"
        case streamYourOwnGame = "e4c1d680-2c70-45e4-a38d-8a292c68c700"
        case freeWithAds = "51f14e5d-bdcb-4e04-b9cb-76e5057702df"
    }

    private let http: HTTPClient
    private let market: String
    private let language: String

    public init(http: HTTPClient, market: String, language: String) {
        self.http = http
        self.market = market
        self.language = language
    }

    public func products(_ ids: [String]) async throws -> [String: CatalogProduct] {
        let uniqueIDs = Array(Set(ids.map { $0.uppercased() }.filter { !$0.isEmpty })).sorted()
        guard !uniqueIDs.isEmpty else {
            return [:]
        }

        let outcomes = await withTaskGroup(of: Result<[CatalogProduct], Error>.self) { group in
            for batch in batches(of: uniqueIDs) {
                group.addTask { await productsRetryingThenSplitting(batch) }
            }

            var outcomes: [Result<[CatalogProduct], Error>] = []

            for await outcome in group {
                outcomes.append(outcome)
            }

            return outcomes
        }

        return try productsByID(merging: outcomes)
    }

    public func list(_ list: List) async throws -> CuratedList {
        let url = URL(string: "https://catalog.gamepass.com/sigls/v2")!
            .appending(queryItems: [
                URLQueryItem(name: "id", value: list.rawValue),
                URLQueryItem(name: "market", value: market),
                URLQueryItem(name: "language", value: language),
            ])
        let body = try await http.successfulBody(
            for: .init(url: url, headers: ["Accept": "application/json"])
        )
        let entries = (try JSONSerialization.jsonObject(with: body) as? [[String: Any]]) ?? []
        let title = entries.first?["title"] as? String ?? ""
        let productIDs = entries.dropFirst().compactMap { $0["id"] as? String }
        return .init(id: list.rawValue, title: title, productIDs: productIDs)
    }
}

// MARK: - Private

private extension CatalogClient {
    var batchSize: Int {
        100
    }

    func batches(of ids: [String]) -> [[String]] {
        stride(from: 0, to: ids.count, by: batchSize).map { start in
            Array(ids[start..<min(start + batchSize, ids.count)])
        }
    }

    func productsRetryingThenSplitting(_ ids: [String]) async -> Result<[CatalogProduct], Error> {
        do {
            return .success(try await productBatch(ids))
        } catch {
            return await productsRetrying(ids, after: error)
        }
    }

    func productsRetrying(
        _ ids: [String],
        after error: Error
    ) async -> Result<[CatalogProduct], Error> {
        switch (try? await productBatch(ids), ids.count > 1) {
        case (let retried?, _): return .success(retried)
        case (nil, false): return .failure(error)
        case (nil, true): return await productsSplittingInHalves(ids, after: error)
        }
    }

    func productsSplittingInHalves(
        _ ids: [String],
        after error: Error
    ) async -> Result<[CatalogProduct], Error> {
        let middle = ids.count / 2
        async let first = productsRetryingThenSplitting(Array(ids[..<middle]))
        async let second = productsRetryingThenSplitting(Array(ids[middle...]))
        let halves = await [first, second]
        let products = halves.flatMap { (try? $0.get()) ?? [] }
        return products.isEmpty ? .failure(error) : .success(products)
    }

    func productBatch(_ ids: [String]) async throws -> [CatalogProduct] {
        let url = URL(string: "https://catalog.gamepass.com/v3/products")!
            .appending(queryItems: [
                URLQueryItem(name: "market", value: market),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "hydration", value: "RemoteHighSapphire0"),
            ])
        let body = try await http.successfulBody(
            for: .init(
                url: url,
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "ms-cv": "0",
                    "calling-app-name": "Xbox Cloud Gaming Web",
                    "calling-app-version": "24.17.63",
                ],
                body: try JSONSerialization.data(withJSONObject: ["Products": ids])
            )
        )
        return products(in: body)
    }

    func products(in body: Data) -> [CatalogProduct] {
        guard
            let root = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let products = root["Products"] as? [String: [String: Any]]
        else {
            return []
        }

        return products.compactMap { storeKey, fields in
            CatalogProduct(storeKey: storeKey, fields: fields)
        }
    }

    func productsByID(
        merging outcomes: [Result<[CatalogProduct], Error>]
    ) throws -> [String: CatalogProduct] {
        var productsByID: [String: CatalogProduct] = [:]
        var lastError: Error?

        for outcome in outcomes {
            switch outcome {
            case .success(let products):
                for product in products {
                    productsByID[product.id.uppercased()] = product
                }
            case .failure(let error): lastError = error
            }
        }

        switch (productsByID.isEmpty, lastError) {
        case (true, let lastError?): throw lastError
        default: return productsByID
        }
    }
}
