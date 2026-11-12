//
//  XboxLiveTokenClient.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct XboxLiveTokenClient: Sendable {
    enum RelyingParty: String, Sendable {
        case xboxLive = "http://xboxlive.com"
        case gssv = "http://gssv.xboxlive.com/"
    }

    private let identity: MicrosoftIdentity
    private let http: HTTPClient
    private let now: @Sendable () -> Date

    init(
        identity: MicrosoftIdentity,
        http: HTTPClient,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.identity = identity
        self.http = http
        self.now = now
    }

    func userToken(microsoftAccessToken: String) async throws -> XboxToken {
        let body: [String: Any] = [
            "Properties": [
                "AuthMethod": "RPS",
                "RpsTicket": "d=\(microsoftAccessToken)",
                "SiteName": "user.auth.xboxlive.com",
            ],
            "RelyingParty": "http://auth.xboxlive.com",
            "TokenType": "JWT",
        ]
        return try await xboxToken(posting: body, to: userAuthenticationURL)
    }

    func securityToken(userToken: XboxToken, relyingParty: RelyingParty) async throws -> XboxToken {
        let body: [String: Any] = [
            "Properties": ["SandboxId": "RETAIL", "UserTokens": [userToken.token]],
            "RelyingParty": relyingParty.rawValue,
            "TokenType": "JWT",
        ]
        return try await xboxToken(posting: body, to: securityTokenURL)
    }

    func streamingToken(
        gssvToken: XboxToken,
        offering: StreamingOffering
    ) async throws -> StreamingToken {
        let response = try await http.decodedBody(
            StreamingLoginResponse.self,
            for: .init(
                url: offering.loginURL,
                method: "POST",
                headers: [
                    "Content-Type": "application/json",
                    "Cache-Control": "no-store, must-revalidate, no-cache",
                    "x-gssv-client": "XboxComBrowser",
                ],
                body: try encoded(["token": gssvToken.token, "offeringId": offering.rawValue])
            )
        )
        return .init(
            offering: offering,
            token: response.gameStreamingToken,
            expiresAt: now().addingTimeInterval(TimeInterval(response.durationInSeconds)),
            market: response.market,
            regions: response.offeringSettings.regions.compactMap(streamingRegion)
        )
    }

    func transferToken(refreshToken: String) async throws -> String {
        let form = FormBody([
            ("client_id", identity.clientID),
            ("grant_type", "refresh_token"),
            ("refresh_token", refreshToken),
            ("scope", transferTokenScope),
        ])
        let response = try await http.decodedBody(
            TransferTokenResponse.self,
            for: .init(
                url: URL(string: "https://login.live.com/oauth20_token.srf")!,
                method: "POST",
                headers: form.headers.merging(
                    ["Cache-Control": "no-store, must-revalidate, no-cache"]
                ) { existing, _ in existing },
                body: form.encoded
            )
        )
        return response.accessToken
    }
}

// MARK: - Private

private extension XboxLiveTokenClient {
    struct TokenResponse: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case token = "Token"
            case notAfter = "NotAfter"
            case displayClaims = "DisplayClaims"
        }

        struct Claims: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case users = "xui"
            }

            let users: [User]
        }

        struct User: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case userHash = "uhs"
                case gamertag = "gtg"
                case xuid = "xid"
            }

            let userHash: String
            let gamertag: String?
            let xuid: String?
        }

        let token: String
        let notAfter: Date
        let displayClaims: Claims

        func xboxToken() throws -> XboxToken {
            guard let user = displayClaims.users.first else {
                throw URLError(.cannotParseResponse)
            }

            return .init(
                token: token,
                notAfter: notAfter,
                userHash: user.userHash,
                gamertag: user.gamertag,
                xuid: user.xuid
            )
        }
    }

    struct StreamingLoginResponse: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case offeringSettings
            case market
            case gameStreamingToken = "gsToken"
            case durationInSeconds
        }

        struct OfferingSettings: Decodable, Sendable {
            let regions: [Region]
        }

        struct Region: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case name
                case baseURI = "baseUri"
                case isDefault
                case fallbackPriority
            }

            let name: String
            let baseURI: String
            let isDefault: Bool?
            let fallbackPriority: Int?
        }

        let offeringSettings: OfferingSettings
        let market: String?
        let gameStreamingToken: String
        let durationInSeconds: Int
    }

    struct TransferTokenResponse: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }

        let accessToken: String
    }

    var userAuthenticationURL: URL {
        URL(string: "https://user.auth.xboxlive.com/user/authenticate")!
    }

    var securityTokenURL: URL {
        URL(string: "https://xsts.auth.xboxlive.com/xsts/authorize")!
    }

    var xboxComBrowserHeaders: [String: String] {
        [
            "x-xbl-contract-version": "1",
            "Cache-Control": "no-cache",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Origin": "https://www.xbox.com",
            "Referer": "https://www.xbox.com/",
        ]
    }

    var unrankedFallbackPriority: Int {
        -1
    }

    var transferTokenScope: String {
        "service::http://Passport.NET/purpose::PURPOSE_XBOX_CLOUD_CONSOLE_TRANSFER_TOKEN"
    }

    func xboxToken(posting body: [String: Any], to url: URL) async throws -> XboxToken {
        let request = HTTPClient.Request(
            url: url,
            method: "POST",
            headers: xboxComBrowserHeaders,
            body: try encoded(body)
        )
        let response = try await http.decodedBody(TokenResponse.self, for: request)
        return try response.xboxToken()
    }

    func encoded(_ body: [String: Any]) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: body,
            options: [.withoutEscapingSlashes, .sortedKeys]
        )
    }

    func streamingRegion(_ region: StreamingLoginResponse.Region) -> StreamingRegion? {
        guard let baseURL = URL(string: region.baseURI) else {
            return nil
        }

        return .init(
            name: region.name,
            baseURL: baseURL,
            isDefault: region.isDefault ?? false,
            fallbackPriority: region.fallbackPriority ?? unrankedFallbackPriority
        )
    }
}
