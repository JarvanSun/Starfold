//
//  AccountStore.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

public struct AccountStore: Sendable {
    private let identity: MicrosoftIdentity
    private let secrets: SecretStoring
    private let http: HTTPClient
    private let now: @Sendable () -> Date
    private let accountKeyPrefix = "account."

    public init(
        microsoftClientID: String,
        secrets: SecretStoring,
        http: HTTPClient = HTTPClient(),
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.identity = MicrosoftIdentity(clientID: microsoftClientID)
        self.secrets = secrets
        self.http = http
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
        let keys = (try? secrets.allKeys()) ?? []
        return keys.filter(isAccountKey)
            .compactMap(restoredAccount(key:))
            .sorted { $0.xuid < $1.xuid }
    }

    public func signOut(xuid: String) throws {
        try secrets.delete(secretKey(for: xuid))
    }
}

private extension AccountStore {
    var deviceCodeFlow: DeviceCodeFlow {
        .init(configuration: identity.deviceCodeConfiguration, http: http, now: now)
    }

    var tokenClient: XboxLiveTokenClient {
        .init(identity: identity, http: http, now: now)
    }

    func save(_ stored: StoredAccount) throws {
        try secrets.write(try JSONEncoder().encode(stored), for: secretKey(for: stored.xuid))
    }

    func secretKey(for xuid: String) -> String {
        accountKeyPrefix + xuid
    }

    func account(for stored: StoredAccount) -> XboxAccount {
        .init(
            stored: stored,
            deviceCodeFlow: deviceCodeFlow,
            tokenClient: tokenClient,
            persist: { account in try save(account) },
            now: now
        )
    }

    func isAccountKey(_ key: String) -> Bool {
        key.hasPrefix(accountKeyPrefix)
    }

    func restoredAccount(key: String) -> XboxAccount? {
        guard
            let secret = try? secrets.read(key),
            let stored = try? JSONDecoder().decode(StoredAccount.self, from: secret)
        else {
            return nil
        }

        return account(for: stored)
    }
}
