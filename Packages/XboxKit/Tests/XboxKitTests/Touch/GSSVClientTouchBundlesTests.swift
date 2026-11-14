//
//  GSSVClientTouchBundlesTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct GSSVClientTouchBundlesTests {
    @Test
    func inputConfigurationsThenPostsXboxTitleIDsWithTheGSSVToken() async throws {
        // Given
        let server = XboxServerStub()
        let url = "\(XboxEndpoint.homeRegion.rawValue)/v2/titles/inputconfigs"
        server.on(url, json: .dummyInputConfigurations)
        let client = makeClient(server: server)

        // When
        _ = try await client.inputConfigurations(xboxTitleIDs: ["1A2B3C4D", "5E6F7A8B"])

        // Then
        let request = try #require(server.requests(to: url).first)
        let body = try #require(
            request.body.flatMap { try JSONSerialization.jsonObject(with: $0) as? [String: Any] }
        )
        #expect(request.method == "POST")
        #expect(request.headers["Authorization"] == "Bearer gs")
        #expect(request.headers["Content-Type"] == "application/json")
        #expect(body["titleIds"] as? [String] == ["1A2B3C4D", "5E6F7A8B"])
        #expect(body["titleIdType"] as? String == "xboxTitleId")
    }

    @Test
    func inputConfigurationsThenKeepsTheResponseOrder() async throws {
        // Given
        let server = XboxServerStub()
        server.on(
            "\(XboxEndpoint.homeRegion.rawValue)/v2/titles/inputconfigs",
            json: .dummyInputConfigurations
        )
        let client = makeClient(server: server)

        // When
        let configurations = try await client.inputConfigurations(xboxTitleIDs: ["1", "2"])

        // Then
        #expect(configurations.map(\.touchBundleIDs) == [["7c1e2f-touch"], []])
    }

    @Test
    func touchBundleArchiveThenSendsTheTokenOnlyToTheGSSVStep() async throws {
        // Given
        let server = XboxServerStub()
        let downloadURL = "https://touch.example.net/bundles/7c1e2f.zip"
        let stepURL = "\(XboxEndpoint.homeRegion.rawValue)/v1/sessions/tabs/7c1e2f-touch/download"
        server.on(stepURL, json: "\(downloadURL)\n")
        server.on(downloadURL, body: .dummySampleLayoutsBundle)
        let client = makeClient(server: server)

        // When
        let archive = try await client.touchBundleArchive(id: "7c1e2f-touch")

        // Then
        let step = try #require(server.requests(to: stepURL).first)
        let download = try #require(server.requests(to: downloadURL).first)
        #expect(archive == .dummySampleLayoutsBundle)
        #expect(step.method == "GET")
        #expect(step.url.query == "noRedirect=true")
        #expect(step.headers["Authorization"] == "Bearer gs")
        #expect(download.headers["Authorization"] == nil)
        #expect(download.headers.isEmpty)
    }

    @Test(arguments: ["", "not a url", "http://touch.example.net/bundle.zip"])
    func touchBundleArchiveWhenTheDownloadURLIsNotHTTPSThenThrows(text: String) async {
        // Given
        let server = XboxServerStub()
        server.on(
            "\(XboxEndpoint.homeRegion.rawValue)/v1/sessions/tabs/7c1e2f/download",
            json: text
        )
        let client = makeClient(server: server)

        // When / Then
        await #expect(throws: GSSVSessionError.self) {
            try await client.touchBundleArchive(id: "7c1e2f")
        }
        #expect(server.requests.count == 1)
    }

    @Test
    func touchBundleArchiveWhenTheDownloadFailsThenThrowsHTTPError() async {
        // Given
        let server = XboxServerStub()
        let downloadURL = "https://touch.example.net/bundle.zip"
        server.on(
            "\(XboxEndpoint.homeRegion.rawValue)/v1/sessions/tabs/7c1e2f/download",
            json: downloadURL
        )
        server.on(downloadURL, status: 404, json: "")
        let client = makeClient(server: server)

        // When
        let error = await #expect(throws: XboxHTTPError.self) {
            try await client.touchBundleArchive(id: "7c1e2f")
        }

        // Then
        #expect(error?.statusCode == 404)
    }
}

private extension GSSVClientTouchBundlesTests {
    func makeClient(server: XboxServerStub) -> GSSVClient {
        .init(
            kind: .home,
            baseURL: URL(string: XboxEndpoint.homeRegion.rawValue)!,
            httpClient: server.client
        ) { _ in "gs" }
    }
}
