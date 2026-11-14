//
//  XboxAccount.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import os

public actor XboxAccount {
    public nonisolated let xuid: String

    private let deviceCodeFlow: DeviceCodeFlow
    private let tokenClient: XboxLiveTokenClient
    private let persist: @Sendable (StoredAccount) throws -> Void
    private let now: @Sendable () -> Date
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Starfold",
        category: "Account"
    )

    private var storedAccount: StoredAccount
    private var userToken: XboxToken?
    private var refreshTask: Task<MicrosoftAccountToken, Error>?

    public var gamertag: String {
        storedAccount.gamertag
    }

    public var isFreeToPlayCloud: Bool {
        storedAccount.cloudOffering == .cloudFreeToPlay
    }

    public var market: String? {
        storedAccount.streamingTokens.values.compactMap(\.market).first
    }

    init(
        storedAccount: StoredAccount,
        deviceCodeFlow: DeviceCodeFlow,
        tokenClient: XboxLiveTokenClient,
        persist: @escaping @Sendable (StoredAccount) throws -> Void,
        now: @escaping @Sendable () -> Date
    ) {
        self.xuid = storedAccount.xuid
        self.storedAccount = storedAccount
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

    private func validMicrosoftAccountToken() async throws -> MicrosoftAccountToken {
        switch (storedAccount.microsoftAccountToken.isValid(at: now()), refreshTask) {
        case (true, _): return storedAccount.microsoftAccountToken
        case (false, let refreshTask?): return try await refreshTask.value
        case (false, nil): return try await refreshMicrosoftAccountToken()
        }
    }

    private func refreshMicrosoftAccountToken() async throws -> MicrosoftAccountToken {
        let current = storedAccount.microsoftAccountToken
        let flow = deviceCodeFlow
        let task = Task { try await flow.refresh(current) }
        refreshTask = task
        defer { refreshTask = nil }

        do {
            let refreshed = try await task.value
            storedAccount.microsoftAccountToken = refreshed

            save()

            return refreshed
        } catch let error as XboxHTTPError where error.isRequestLoop {
            throw error
        } catch let error as XboxHTTPError where [400, 401].contains(error.statusCode) {
            throw XboxAccountError.signInRequired
        } catch DeviceCodeError.expired {
            throw XboxAccountError.signInRequired
        }
    }

    private func save() {
        do {
            try persist(storedAccount)
        } catch {
            log.error("Saving the account failed: \(String(describing: error), privacy: .public)")
        }
    }

    public func makeHomeClient(httpClient: HTTPClient) async throws -> GSSVClient {
        let token = try await homeStreamingToken()
        guard let region = token.defaultRegion else {
            throw XboxHTTPError(
                url: StreamingOffering.home.loginURL,
                statusCode: 0,
                body: "No regions",
                headers: [:]
            )
        }

        return .init(kind: .home, baseURL: region.baseURL, httpClient: httpClient) {
            [self] freshness in
            if freshness == .refreshRequired {
                await invalidateStreamingToken(.home)
            }

            return try await homeStreamingToken().token
        }
    }

    private func invalidateStreamingToken(_ offering: StreamingOffering) {
        storedAccount.streamingTokens[offering] = nil

        save()
    }

    public func makeCloudClient(httpClient: HTTPClient) async throws -> GSSVClient {
        let token = try await cloudStreamingToken()
        guard let region = token.defaultRegion else {
            throw XboxAccountError.cloudGamingUnavailable
        }

        let offering = token.offering
        return .init(kind: .cloud, baseURL: region.baseURL, httpClient: httpClient) {
            [self] freshness in
            if freshness == .refreshRequired {
                await invalidateStreamingToken(offering)
            }

            return try await cloudStreamingToken().token
        }
    }

    func webAuthorization() async throws -> String {
        if let cached = storedAccount.webToken, cached.isValid(at: now()) {
            return cached.authorizationHeader
        }

        let token = try await tokenClient.securityToken(
            userToken: try await validUserToken(),
            relyingParty: .xboxLive
        )
        storedAccount.webToken = token

        if let gamertag = token.gamertag {
            storedAccount.gamertag = gamertag
        }

        save()

        return token.authorizationHeader
    }

    private func validUserToken() async throws -> XboxToken {
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

    func homeStreamingToken() async throws -> StreamingToken {
        try await streamingToken(.home)
    }

    private func streamingToken(_ offering: StreamingOffering) async throws -> StreamingToken {
        if let cached = storedAccount.streamingTokens[offering], cached.isValid(at: now()) {
            return cached
        }

        let token = try await tokenClient.streamingToken(
            gssvToken: try await validGSSVToken(),
            offering: offering
        )
        storedAccount.streamingTokens[offering] = token

        save()

        return token
    }

    private func validGSSVToken() async throws -> XboxToken {
        if let cached = storedAccount.gssvToken, cached.isValid(at: now()) {
            return cached
        }

        let token = try await tokenClient.securityToken(
            userToken: try await validUserToken(),
            relyingParty: .gssv
        )
        storedAccount.gssvToken = token

        save()

        return token
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

    private func rememberCloudOffering(_ offering: StreamingOffering) {
        if storedAccount.cloudOffering != offering {
            storedAccount.cloudOffering = offering

            save()
        }
    }

    private func forgetLapsedCloudOffering() {
        if storedAccount.cloudOffering != nil {
            storedAccount.cloudOffering = nil

            save()
        }
    }

    private var cloudOfferingCandidates: [StreamingOffering] {
        storedAccount.cloudOffering.map { [$0] } ?? [.cloud, .cloudFreeToPlay]
    }
}
