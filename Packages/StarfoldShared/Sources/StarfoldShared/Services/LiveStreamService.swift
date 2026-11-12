//
//  LiveStreamService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import XboxKit
import os

struct LiveStreamService: StreamService {
    private let account: XboxAccount
    private let http: HTTPClient
    private let runtime: StreamRuntime
    private let log = Logger(category: .stream)

    init(account: XboxAccount, http: HTTPClient, runtime: StreamRuntime) {
        self.account = account
        self.http = http
        self.runtime = runtime
    }

    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection {
        let pressed = ContinuousClock.now
        let client = try await streamingClient(for: target)
        log.info(
            "Startup streaming token ready +\((ContinuousClock.now - pressed).formatted(.units(allowed: [.milliseconds])), privacy: .public)"
        )

        let controller = StreamController(
            client: client,
            target: target,
            options: options,
            transferToken: { [account] in try await account.transferToken() }
        )
        return LiveStreamConnection(controller: controller, runtime: runtime)
    }

    func setDirectStereo(_ isEnabled: Bool) {
        #if !os(macOS)
        runtime.setDirectStereo(isEnabled)
        #endif
    }
}

private extension LiveStreamService {
    func streamingClient(for target: StreamTarget) async throws -> GSSVClient {
        switch target {
        case .console: try await account.homeClient(http: http)
        case .cloud: try await account.cloudClient(http: http)
        }
    }
}
