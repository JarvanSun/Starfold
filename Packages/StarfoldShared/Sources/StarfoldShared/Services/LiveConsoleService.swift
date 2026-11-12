//
//  LiveConsoleService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

struct LiveConsoleService: ConsoleService {
    private let account: XboxAccount
    private let http: HTTPClient

    init(account: XboxAccount, http: HTTPClient) {
        self.account = account
        self.http = http
    }

    func consoles() async throws -> [Console] {
        let remotePlayConsoles = try await account.homeClient(http: http).consoles()
        guard remotePlayConsoles.isEmpty else { return remotePlayConsoles }

        return try await xboxLive.consoles()
    }

    func activity() async throws -> ConsoleActivity? {
        try await xboxLive.consoleActivity(xuid: account.xuid)
    }

    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws {
        try await xboxLive.send(command, to: consoleID)
    }
}

private extension LiveConsoleService {
    var xboxLive: XboxLiveClient {
        .init(account: account, http: http)
    }
}
