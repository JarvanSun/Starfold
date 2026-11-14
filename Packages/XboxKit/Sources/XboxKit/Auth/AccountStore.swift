//
//  AccountStore.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public struct AccountStore: Sendable {
    private let microsoftIdentity: MicrosoftIdentity
    private let secretStore: SecretStoring
    private let httpClient: HTTPClient
    private let now: @Sendable () -> Date
    private let accountKeyPrefix = "account."

    private var deviceCodeFlow: DeviceCodeFlow {
        .init(
            configuration: microsoftIdentity.deviceCodeConfiguration,
            httpClient: httpClient,
            now: now
        )
    }

    private var tokenClient: XboxLiveTokenClient {
        .init(microsoftIdentity: microsoftIdentity, httpClient: httpClient, now: now)
    }

    public init(
        microsoftClientID: String,
        secretStore: SecretStoring,
        httpClient: HTTPClient = HTTPClient(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.microsoftIdentity = MicrosoftIdentity(clientID: microsoftClientID)
        self.secretStore = secretStore
        self.httpClient = httpClient
        self.now = now
    }

    public func beginSignIn() async throws -> DeviceCodePrompt {
        try await deviceCodeFlow.start()
    }

    public func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @Sendable () async -> Void = {}
    ) async throws -> XboxAccount {
        let microsoftToken = try await deviceCodeFlow.waitForToken(prompt)

        await onAuthorized()

        let userToken = try await tokenClient.userToken(
            microsoftAccessToken: microsoftToken.accessToken
        )
        let webToken = try await tokenClient.securityToken(
            userToken: userToken,
            relyingParty: .xboxLive
        )
        guard let xuid = webToken.xuid else {
            throw URLError(.userAuthenticationRequired)
        }

        let stored = StoredAccount(
            xuid: xuid,
            gamertag: webToken.gamertag ?? xuid,
            microsoftAccountToken: microsoftToken,
            webToken: webToken
        )
        try save(stored)

        return account(for: stored)
    }

    public func restoreAccounts() -> [XboxAccount] {
        let keys = (try? secretStore.allKeys()) ?? []
        return keys.filter(isAccountKey)
            .compactMap(restoredAccount(key:))
            .sorted { $0.xuid < $1.xuid }
    }

    private func isAccountKey(_ key: String) -> Bool {
        key.hasPrefix(accountKeyPrefix)
    }

    private func restoredAccount(key: String) -> XboxAccount? {
        guard
            let secret = try? secretStore.read(key),
            let stored = try? JSONDecoder().decode(StoredAccount.self, from: secret)
        else {
            return nil
        }

        return account(for: stored)
    }

    private func account(for stored: StoredAccount) -> XboxAccount {
        .init(
            storedAccount: stored,
            deviceCodeFlow: deviceCodeFlow,
            tokenClient: tokenClient,
            persist: { account in try save(account) },
            now: now
        )
    }

    private func save(_ stored: StoredAccount) throws {
        try secretStore.write(try JSONEncoder().encode(stored), for: secretKey(for: stored.xuid))
    }

    private func secretKey(for xuid: String) -> String {
        accountKeyPrefix + xuid
    }

    public func signOut(xuid: String) throws {
        try secretStore.delete(secretKey(for: xuid))
    }
}
