//
//  XboxLiveClient.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public struct XboxLiveClient: Sendable {
    public enum PowerCommand: String, Sendable {
        case wakeUp = "WakeUp"
        case turnOff = "TurnOff"
    }

    struct CommandRejected: Error, Equatable, Sendable {
        let code: String
        let message: String?
    }

    private let http: HTTPClient
    private let authorization: @Sendable () async throws -> String

    init(http: HTTPClient, authorization: @escaping @Sendable () async throws -> String) {
        self.http = http
        self.authorization = authorization
    }

    public init(account: XboxAccount, http: HTTPClient) {
        self.init(http: http, authorization: { try await account.webAuthorization() })
    }

    public func profile() async throws -> XboxProfile {
        let response = try await http.decodedBody(
            ProfileResponse.self,
            for: .init(
                url: URL(string: "https://profile.xboxlive.com/users/me/profile/settings")!
                    .appending(queryItems: [
                        URLQueryItem(
                            name: "settings",
                            value: "Gamertag,ModernGamertag,Gamerscore,GameDisplayPicRaw"
                        )
                    ]),
                headers: try await headers(contractVersion: 3)
            )
        )
        guard let user = response.profileUsers.first else {
            throw URLError(.cannotParseResponse)
        }

        return profile(of: user)
    }

    public func consoleActivity(xuid: String) async throws -> ConsoleActivity? {
        async let presence = currentConsoleTitle(xuid: xuid)
        async let history = recentTitles(xuid: xuid)
        let current = try? await presence
        let titles = try await history
        return current.map { current in
            let known = titles.first { $0.titleID == current.id }
            return .init(
                titleID: current.id,
                name: known?.name ?? current.name,
                imageURL: known?.wideImageURL,
                kind: .playingNow
            )
        }
    }

    public func consoles() async throws -> [Console] {
        let response = try await http.decodedBody(
            DeviceListResponse.self,
            for: .init(
                url: URL(
                    string:
                        "https://xccs.xboxlive.com/lists/devices?queryCurrentDevice=false&includeStorageDevices=true"
                )!,
                headers: try await headers(contractVersion: 2)
            )
        )
        return response.result.map { device in
            Console(
                id: device.id,
                name: device.name,
                consoleType: device.consoleType ?? "Xbox",
                powerState: device.powerState ?? .unknown
            )
        }
    }

    public func send(_ command: PowerCommand, to consoleID: String) async throws {
        let body: [String: Any] = [
            "destination": "Xbox",
            "type": "Power",
            "command": command.rawValue,
            "sessionId": UUID().uuidString.lowercased(),
            "sourceId": "com.microsoft.smartglass",
            "parameters": [],
            "linkedXboxId": consoleID,
        ]

        let spinnerTimeout: Duration = .seconds(10)
        let reply = try await http.successfulBody(
            for: .init(
                url: URL(string: "https://xccs.xboxlive.com/commands")!,
                method: "POST",
                headers: try await headers(
                    contractVersion: 4,
                    adding: [
                        "skillplatform": "RemoteManagement",
                        "Content-Type": "application/json",
                    ]
                ),
                body: try JSONSerialization.data(
                    withJSONObject: body,
                    options: [.withoutEscapingSlashes]
                ),
                timeout: spinnerTimeout
            )
        )

        if let rejection = rejection(in: reply) {
            throw rejection
        }
    }
}

// MARK: - Private

private extension XboxLiveClient {
    struct ProfileResponse: Decodable, Sendable {
        struct User: Decodable, Sendable {
            let id: String
            let settings: [Setting]
        }

        struct Setting: Decodable, Sendable {
            let id: String
            let value: String
        }

        let profileUsers: [User]
    }

    struct PresenceResponse: Decodable, Sendable {
        struct Device: Decodable, Sendable {
            let type: String
            let titles: [Title]?
        }

        struct Title: Decodable, Sendable {
            let id: String
            let name: String
            let placement: String?
            let state: String?
        }

        let devices: [Device]?
    }

    struct TitleHistoryResponse: Decodable, Sendable {
        let titles: [HistoryTitle]
    }

    struct HistoryTitle: Decodable, Sendable {
        enum CodingKeys: String, CodingKey {
            case titleID = "titleId"
            case name
            case displayImage
            case images
        }

        struct Image: Decodable, Sendable {
            let url: String
            let type: String
        }

        let titleID: String
        let name: String
        let displayImage: String?
        let images: [Image]?

        var wideImageURL: URL? {
            let wideArtTypes = [
                "SuperHeroArt", "TitledHeroArt", "BrandedKeyArt", "Screenshot", "Poster", "BoxArt",
            ]
            let wideArt = wideArtTypes.lazy.compactMap(image(ofType:)).first
            return (wideArt ?? displayImage).flatMap(URL.init(upgradingXboxImageToHTTPS:))
        }

        private func image(ofType type: String) -> String? {
            images?.first { $0.type == type }?.url
        }
    }

    struct DeviceListResponse: Decodable, Sendable {
        struct Device: Decodable, Sendable {
            let id: String
            let name: String
            let consoleType: String?
            let powerState: Console.PowerState?
        }

        let result: [Device]
    }

    struct CommandReply: Decodable {
        struct Status: Decodable {
            let errorCode: String?
            let errorMessage: String?
        }

        let status: Status?
    }

    func headers(
        contractVersion: Int,
        adding extraHeaders: [String: String] = [:]
    ) async throws -> [String: String] {
        var headers = [
            "Authorization": try await authorization(),
            "x-xbl-contract-version": String(contractVersion),
            "Accept-Language": Locale.preferredLanguages.first ?? "en-US",
            "Accept": "application/json",
            "x-xbl-client-name": "XboxApp",
            "x-xbl-client-type": "UWA",
            "x-xbl-client-version": "39.39.22001.0",
        ]
        headers.merge(extraHeaders) { _, new in new }
        return headers
    }

    func profile(of user: ProfileResponse.User) -> XboxProfile {
        let settings = Dictionary(user.settings.map { ($0.id, $0.value) }) { first, _ in first }
        let modernGamertag = settings["ModernGamertag"].flatMap { $0.isEmpty ? nil : $0 }
        return .init(
            xuid: user.id,
            gamertag: modernGamertag ?? settings["Gamertag"] ?? user.id,
            gamerscore: settings["Gamerscore"].flatMap(Int.init),
            pictureURL: settings["GameDisplayPicRaw"].flatMap(URL.init(upgradingXboxImageToHTTPS:))
        )
    }

    func currentConsoleTitle(xuid: String) async throws -> PresenceResponse.Title? {
        let response = try await http.decodedBody(
            PresenceResponse.self,
            for: .init(
                url: URL(
                    string: "https://userpresence.xboxlive.com/users/xuid(\(xuid))?level=all"
                )!,
                headers: try await headers(contractVersion: 3)
            )
        )

        let consoleDeviceTypes: Set<String> = ["Scarlett", "XboxOne"]
        let consoles = (response.devices ?? []).filter { consoleDeviceTypes.contains($0.type) }
        let titles = consoles.flatMap { $0.titles ?? [] }.filter(isActiveGame)
        return titles.first { $0.placement == "Full" } ?? titles.first
    }

    func isActiveGame(_ title: PresenceResponse.Title) -> Bool {
        let dashboardTitleID = "750323071"

        return title.id != dashboardTitleID && title.state != "Inactive"
    }

    func recentTitles(xuid: String) async throws -> [HistoryTitle] {
        let response = try await http.decodedBody(
            TitleHistoryResponse.self,
            for: .init(
                url: URL(
                    string:
                        "https://titlehub.xboxlive.com/users/xuid(\(xuid))/titles/titlehistory/decoration/image?maxItems=10"
                )!,
                headers: try await headers(contractVersion: 2)
            )
        )
        return response.titles
    }

    func rejection(in reply: Data) -> CommandRejected? {
        guard
            let status = (try? JSONDecoder().decode(CommandReply.self, from: reply))?.status,
            let code = status.errorCode,
            code != "OK"
        else {
            return nil
        }

        return .init(code: code, message: status.errorMessage)
    }
}
