//
//  HTTPClientTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct HTTPClientTests {
    @Test
    func successfulBodyWhenStatusIsNotSuccessThenThrowsHTTPErrorWithBody() async {
        // Given
        let server = XboxServerStub()
        server.on(.consoleCommands, status: 503, json: "busy")
        let client = server.httpClient
        let request = HTTPClient.Request(url: URL(string: XboxEndpoint.consoleCommands.rawValue)!)

        // When
        let error = await #expect(throws: XboxHTTPError.self) {
            _ = try await client.successfulBody(for: request)
        }

        // Then
        #expect(error?.statusCode == 503)
        #expect(error?.body == "busy")
    }
}
