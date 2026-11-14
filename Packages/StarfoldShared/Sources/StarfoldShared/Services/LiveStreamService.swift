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
    private let xboxAccount: XboxAccount
    private let httpClient: HTTPClient
    private let streamRuntime: StreamRuntime
    private let log = Logger(category: .stream)

    init(xboxAccount: XboxAccount, httpClient: HTTPClient, streamRuntime: StreamRuntime) {
        self.xboxAccount = xboxAccount
        self.httpClient = httpClient
        self.streamRuntime = streamRuntime
    }

    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection {
        let pressed = ContinuousClock.now
        let client = try await streamingClient(for: target)
        log.info(
            "Startup streaming token ready +\((ContinuousClock.now - pressed).formatted(.units(allowed: [.milliseconds])), privacy: .public)"
        )

        let controller = StreamController(
            gssvClient: client,
            target: target,
            options: options,
            transferToken: { [xboxAccount] in try await xboxAccount.transferToken() }
        )
        return LiveStreamConnection(streamController: controller, streamRuntime: streamRuntime)
    }

    private func streamingClient(for target: StreamTarget) async throws -> GSSVClient {
        switch target {
        case .console: try await xboxAccount.homeClient(httpClient: httpClient)
        case .cloud: try await xboxAccount.cloudClient(httpClient: httpClient)
        }
    }

    func touchBundle(forTitle titleID: String, on target: StreamTarget) async throws -> TouchBundle?
    {
        let client = try await streamingClient(for: target)
        let configurations = try await client.inputConfigurations(xboxTitleIDs: [titleID])

        guard let bundleID = configurations.first?.touchBundleIDs.first else { return nil }

        let archive = try await client.touchBundleArchive(id: bundleID)
        return try await TouchBundleUnpacker().bundle(from: archive)
    }

    func setDirectStereo(_ isEnabled: Bool) {
        #if !os(macOS)
        streamRuntime.setDirectStereo(isEnabled)
        #endif
    }
}
