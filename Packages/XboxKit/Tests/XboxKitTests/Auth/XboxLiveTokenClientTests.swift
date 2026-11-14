//
//  XboxLiveTokenClientTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct XboxLiveTokenClientTests {
    @Test
    func userTokenThenSendsMicrosoftTokenWithDPrefix() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.userAuthentication, json: .dummyXboxTokenResponse(token: "user"))
        let client = makeClient(server: server)

        // When
        _ = try await client.userToken(microsoftAccessToken: "abc")

        // Then
        let body = try #require(server.requests(to: .userAuthentication).first?.body)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        let properties = try #require(json["Properties"] as? [String: Any])
        #expect(properties["RpsTicket"] as? String == "d=abc")
        #expect(json["RelyingParty"] as? String == "http://auth.xboxlive.com")
    }

    @Test(
        arguments: [
            (XboxLiveTokenClient.RelyingParty.gssv, "http://gssv.xboxlive.com/"),
            (.xboxLive, "http://xboxlive.com"),
        ]
    )
    func relyingPartyThenKeepsExactAddress(
        relyingParty: XboxLiveTokenClient.RelyingParty,
        expected: String
    ) {
        #expect(relyingParty.rawValue == expected)
    }

    @Test
    func streamingTokenThenDefaultRegionIsTheOneMarkedDefault() async throws {
        // Given
        let server = XboxServerStub()
        server.on(.homeLogin, json: .dummyStreamingLoginResponse(token: "home"))
        let client = makeClient(server: server)

        // When
        let token = try await client.streamingToken(
            gssvToken: .init(token: "g", notAfter: .distantFuture, userHash: "1"),
            offering: .home
        )

        // Then
        #expect(token.defaultRegion?.name == "UkSouth")
    }
}

private extension XboxLiveTokenClientTests {
    func makeClient(server: XboxServerStub) -> XboxLiveTokenClient {
        .init(microsoftIdentity: .init(clientID: .dummyClientID), httpClient: server.client)
    }
}
