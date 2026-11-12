//
//  XboxAccount.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public actor XboxAccount {
    public nonisolated let xuid: String

    private let deviceCodeFlow: DeviceCodeFlow
    private let tokenClient: XboxLiveTokenClient
    private let persist: @Sendable (StoredAccount) throws -> Void
    private let now: @Sendable () -> Date

    private var stored: StoredAccount
    private var userToken: XboxToken?
    private var refreshTask: Task<MicrosoftAccountToken, Error>?

    public var gamertag: String {
        stored.gamertag
    }

    public var isFreeToPlayCloud: Bool {
        stored.cloudOffering == .cloudFreeToPlay
    }

    public var market: String? {
        stored.streamingTokens.values.compactMap(\.market).first
    }

    init(
        stored: StoredAccount,
        deviceCodeFlow: DeviceCodeFlow,
        tokenClient: XboxLiveTokenClient,
        persist: @escaping @Sendable (StoredAccount) throws -> Void,
        now: @escaping @Sendable () -> Date
    ) {
        self.xuid = stored.xuid
        self.stored = stored
        self.deviceCodeFlow = deviceCodeFlow
        self.tokenClient = tokenClient
        self.persist = persist
        self.now = now
    }

    public func transferToken() async throws -> String {
        let microsoftToken = try await validMicrosoftAccountToken()
        guard let refreshToken = microsoftToken.refreshToken else {
            throw XboxAccountError.signInRequired
        }

        return try await tokenClient.transferToken(refreshToken: refreshToken)
    }

    public func homeClient(http: HTTPClient) async throws -> GSSVClient {
        let token = try await homeStreamingToken()
        guard let region = token.defaultRegion else {
            throw XboxHTTPError(
                url: StreamingOffering.home.loginURL,
                statusCode: 0,
                body: "No regions",
                headers: [:]
            )
        }

        return .init(kind: .home, baseURL: region.baseURL, http: http) { [self] freshness in
            if freshness == .refreshRequired {
                await invalidateStreamingToken(.home)
            }

            return try await homeStreamingToken().token
        }
    }

    public func cloudClient(http: HTTPClient) async throws -> GSSVClient {
        let token = try await cloudStreamingToken()
        guard let region = token.defaultRegion else {
            throw XboxAccountError.cloudGamingUnavailable
        }

        let offering = token.offering
        return .init(kind: .cloud, baseURL: region.baseURL, http: http) { [self] freshness in
            if freshness == .refreshRequired {
                await invalidateStreamingToken(offering)
            }

            return try await cloudStreamingToken().token
        }
    }

    func webAuthorization() async throws -> String {
        if let cached = stored.webToken, cached.isValid(at: now()) {
            return cached.authorizationHeader
        }

        let token = try await tokenClient.securityToken(
            userToken: try await validUserToken(),
            relyingParty: .xboxLive
        )
        stored.webToken = token

        if let gamertag = token.gamertag {
            stored.gamertag = gamertag
        }

        save()

        return token.authorizationHeader
    }

    func homeStreamingToken() async throws -> StreamingToken {
        try await streamingToken(.home)
    }

    func cloudStreamingToken() async throws -> StreamingToken {
        var lastError: Error = XboxAccountError.cloudGamingUnavailable

        for offering in cloudOfferingCandidates {
            do {
                let token = try await streamingToken(offering)

                rememberCloudOffering(offering)

                return token
            } catch let error as XboxHTTPError where error.statusCode == 403 {
                lastError = error
            }
        }

        forgetLapsedCloudOffering()

        throw lastError is XboxHTTPError ? XboxAccountError.cloudGamingUnavailable : lastError
    }
}

// MARK: - Private

private extension XboxAccount {
    var cloudOfferingCandidates: [StreamingOffering] {
        stored.cloudOffering.map { [$0] } ?? [.cloud, .cloudFreeToPlay]
    }

    func invalidateStreamingToken(_ offering: StreamingOffering) {
        stored.streamingTokens[offering] = nil

        save()
    }

    func rememberCloudOffering(_ offering: StreamingOffering) {
        if stored.cloudOffering != offering {
            stored.cloudOffering = offering

            save()
        }
    }

    func forgetLapsedCloudOffering() {
        if stored.cloudOffering != nil {
            stored.cloudOffering = nil

            save()
        }
    }

    func streamingToken(_ offering: StreamingOffering) async throws -> StreamingToken {
        if let cached = stored.streamingTokens[offering], cached.isValid(at: now()) {
            return cached
        }

        let token = try await tokenClient.streamingToken(
            gssvToken: try await validGSSVToken(),
            offering: offering
        )
        stored.streamingTokens[offering] = token

        save()

        return token
    }

    func validGSSVToken() async throws -> XboxToken {
        if let cached = stored.gssvToken, cached.isValid(at: now()) {
            return cached
        }

        let token = try await tokenClient.securityToken(
            userToken: try await validUserToken(),
            relyingParty: .gssv
        )
        stored.gssvToken = token

        save()

        return token
    }

    func validUserToken() async throws -> XboxToken {
        if let userToken, userToken.isValid(at: now()) {
            return userToken
        }

        let microsoftToken = try await validMicrosoftAccountToken()
        let token = try await tokenClient.userToken(
            microsoftAccessToken: microsoftToken.accessToken
        )
        userToken = token
        return token
    }

    func validMicrosoftAccountToken() async throws -> MicrosoftAccountToken {
        switch (stored.microsoftAccountToken.isValid(at: now()), refreshTask) {
        case (true, _): return stored.microsoftAccountToken
        case (false, let refreshTask?): return try await refreshTask.value
        case (false, nil): return try await refreshMicrosoftAccountToken()
        }
    }

    func refreshMicrosoftAccountToken() async throws -> MicrosoftAccountToken {
        let current = stored.microsoftAccountToken
        let flow = deviceCodeFlow
        let task = Task { try await flow.refresh(current) }
        refreshTask = task
        defer { refreshTask = nil }

        do {
            let refreshed = try await task.value
            stored.microsoftAccountToken = refreshed

            save()

            return refreshed
        } catch let error as XboxHTTPError where [400, 401].contains(error.statusCode) {
            throw XboxAccountError.signInRequired
        } catch DeviceCodeError.expired {
            throw XboxAccountError.signInRequired
        }
    }

    func save() {
        try? persist(stored)
    }
}
