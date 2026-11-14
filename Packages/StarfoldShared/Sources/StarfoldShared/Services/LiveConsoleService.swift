//
//  LiveConsoleService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

struct LiveConsoleService: ConsoleService {
    private let xboxAccount: XboxAccount
    private let httpClient: HTTPClient

    private var xboxLiveClient: XboxLiveClient {
        .init(account: xboxAccount, httpClient: httpClient)
    }

    init(xboxAccount: XboxAccount, httpClient: HTTPClient) {
        self.xboxAccount = xboxAccount
        self.httpClient = httpClient
    }

    func consoles() async throws -> [Console] {
        let remotePlayConsoles = try await xboxAccount.makeHomeClient(httpClient: httpClient)
            .consoles()
        guard remotePlayConsoles.isEmpty else { return remotePlayConsoles }

        return try await xboxLiveClient.consoles()
    }

    func activity() async throws -> ConsoleActivity? {
        try await xboxLiveClient.consoleActivity(xuid: xboxAccount.xuid)
    }

    func send(_ command: XboxLiveClient.PowerCommand, to consoleID: String) async throws {
        try await xboxLiveClient.send(command, to: consoleID)
    }
}
