//
//  GSSVClient.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public struct GSSVClient: Sendable {
    enum Kind: String, Sendable {
        case home
        case cloud
    }

    let kind: Kind
    let baseURL: URL
    let http: HTTPClient

    private let token: @Sendable (TokenFreshness) async throws -> String

    init(
        kind: Kind,
        baseURL: URL,
        http: HTTPClient,
        token: @escaping @Sendable (TokenFreshness) async throws -> String
    ) {
        self.kind = kind
        self.baseURL = baseURL
        self.http = http
        self.token = token
    }

    public func consoles() async throws -> [Console] {
        let response = try await send(
            to: baseURL.appending(path: "v6/servers/home"),
            extraHeaders: ["X-MS-Device-Info": DeviceInfoHeader(quality: .high).json]
        )
        return try decoded(ServersResponse.self, from: response.body).results.map(\.console)
    }

    public func titles() async throws -> [CloudTitle] {
        let response = try await send(to: baseURL.appending(path: "v2/titles"))
        return try decoded(TitlesResponse.self, from: response.body).titles
    }

    public func recentTitles(limit: Int = 25) async throws -> [CloudTitle] {
        let url = baseURL.appending(path: "v2/titles/mru")
            .appending(queryItems: [URLQueryItem(name: "mr", value: String(limit))])
        let response = try await send(to: url)
        return try decoded(TitlesResponse.self, from: response.body).titles
    }

    public func startSession(
        consoleID: String? = nil,
        titleID: String? = nil,
        quality: StreamQuality,
        locale: String
    ) async throws -> GSSVSession {
        let body: [String: Any] = [
            "clientSessionId": "",
            "titleId": titleID ?? "",
            "systemUpdateGroup": "",
            "settings": [
                "nanoVersion": "V3;WebrtcTransport.dll",
                "enableTextToSpeech": false,
                "highContrast": 0,
                "locale": locale,
                "useIceConnection": false,
                "timezoneOffsetMinutes": TimeZone.current.secondsFromGMT() / 60,
                "sdkType": "web",
                "osName": quality.operatingSystemName,
                "enableOptionalDataCollection": false,
            ],
            "serverId": consoleID ?? "",
            "fallbackRegionNames": [],
        ]
        let response = try await send(
            to: baseURL.appending(path: "v5/sessions/\(kind.rawValue)/play"),
            method: "POST",
            body: try JSONSerialization.data(
                withJSONObject: body,
                options: [.withoutEscapingSlashes]
            ),
            extraHeaders: ["X-MS-Device-Info": DeviceInfoHeader(quality: quality).json]
        )
        let sessionPath = try decoded(SessionResponse.self, from: response.body).sessionPath
        return .init(client: self, url: try sessionURL(path: sessionPath), titleID: titleID)
    }

    private func decoded<Body: Decodable>(_ type: Body.Type, from body: Data) throws -> Body {
        try JSONDecoder(dateParser: .init()).decode(type, from: body)
    }

    private func sessionURL(path: String) throws -> URL {
        switch (path.hasPrefix("http"), URL(string: path)) {
        case (true, let absoluteURL?): return absoluteURL
        case (true, nil): throw GSSVSessionError.malformedResponse("sessionPath \(path)")
        case (false, _): return baseURL.appending(path: path)
        }
    }

    func estimatedWait(titleID: String) async throws -> Duration? {
        let response = try await send(to: baseURL.appending(path: "v1/waittime/\(titleID)"))
        let estimate = try JSONSerialization.jsonObject(with: response.body) as? [String: Any]
        return (estimate?["estimatedTotalWaitTimeInSeconds"] as? NSNumber)
            .map { .seconds($0.doubleValue) }
    }

    func send(
        to url: URL,
        method: String = "GET",
        body: Data? = nil,
        extraHeaders: [String: String] = [:]
    ) async throws -> HTTPClient.Response {
        var freshness = TokenFreshness.cachedAllowed

        while true {
            let headers = try await headers(
                freshness: freshness,
                hasBody: body != nil,
                adding: extraHeaders
            )
            let response = try await http.send(
                .init(url: url, method: method, headers: headers, body: body)
            )

            switch (response.isAuthorizationRejected, freshness) {
            case (true, .cachedAllowed): freshness = .refreshRequired
            default: return try successful(response, from: url)
            }
        }
    }

    private func successful(_ response: HTTPClient.Response, from url: URL) throws
        -> HTTPClient.Response
    {
        guard (200..<300).contains(response.statusCode) else {
            throw XboxHTTPError(
                url: url,
                statusCode: response.statusCode,
                body: String(decoding: response.body, as: UTF8.self),
                headers: response.headers
            )
        }

        return response
    }

    private func headers(
        freshness: TokenFreshness,
        hasBody: Bool,
        adding extraHeaders: [String: String]
    ) async throws -> [String: String] {
        var headers = [
            "Authorization": "Bearer \(try await token(freshness))",
            "Accept": "application/json",
            "X-Gssv-Client": "XboxComBrowser",
        ]

        if hasBody {
            headers["Content-Type"] = "application/json"
        }

        headers.merge(extraHeaders) { _, new in new }
        return headers
    }
}

// MARK: - Private

private extension GSSVClient {
    struct ServersResponse: Decodable, Sendable {
        struct Server: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case serverID = "serverId"
                case deviceName
                case consoleType
                case powerState
                case outOfHomeWarning
                case wirelessWarning
            }

            let serverID: String
            let deviceName: String
            let consoleType: String?
            let powerState: Console.PowerState?
            let outOfHomeWarning: Bool?
            let wirelessWarning: Bool?

            var console: Console {
                .init(
                    id: serverID,
                    name: deviceName,
                    consoleType: consoleType ?? "Xbox",
                    powerState: powerState ?? .unknown,
                    hasOutOfHomeWarning: outOfHomeWarning ?? false,
                    hasWirelessWarning: wirelessWarning ?? false
                )
            }
        }

        let results: [Server]
    }

    struct TitlesResponse: Decodable, Sendable {
        struct Title: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case titleID = "titleId"
                case details
                case titleHistory
            }

            let titleID: String
            let details: Details
            let titleHistory: History?

            var cloudTitle: CloudTitle {
                .init(
                    id: titleID,
                    productID: details.productID ?? "",
                    hasEntitlement: details.hasEntitlement ?? false,
                    isFreeInStore: details.isFreeInStore ?? false,
                    supportedInputTypes: details.supportedInputTypes ?? [],
                    touchBundleIDs: details.supportedTabs?.map(\.id) ?? [],
                    lastPlayed: titleHistory?.lastTimePlayed,
                    userSubscriptions: details.userSubscriptions ?? []
                )
            }
        }

        struct Details: Decodable, Sendable {
            enum CodingKeys: String, CodingKey {
                case productID = "productId"
                case hasEntitlement
                case isFreeInStore
                case supportedInputTypes
                case supportedTabs
                case userSubscriptions
            }

            struct Tab: Decodable, Sendable {
                let id: String
            }

            let productID: String?
            let hasEntitlement: Bool?
            let isFreeInStore: Bool?
            let supportedInputTypes: [String]?
            let supportedTabs: [Tab]?
            let userSubscriptions: [String]?
        }

        struct History: Decodable, Sendable {
            let lastTimePlayed: Date?
        }

        let results: [Title]

        var titles: [CloudTitle] {
            results.map(\.cloudTitle)
        }
    }

    struct SessionResponse: Decodable, Sendable {
        let sessionPath: String
    }
}
