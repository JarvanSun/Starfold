//
//  AppDependencies.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import XboxKit

public struct AppDependencies {
    private let streamPlatform: StreamPlatform

    public init(streamPlatform: StreamPlatform) {
        self.streamPlatform = streamPlatform
    }

    public func makeAppViewModel() -> AppViewModel {
        let httpClient = HTTPClient()
        let preferences = Preferences(defaults: .standard)
        let controllers = ControllerHub(
            controllerRouting: streamPlatform.controllerRouting,
            touchControllerCategory: streamPlatform.touchPlatform?.controllerCategory
        )
        let network = LiveNetworkPath()
        let accountsKeychainService = "\(bundleID).accounts"
        let accountService = LiveAccountService(
            accountStore: .init(
                microsoftClientID: microsoftClientID,
                secretStore: KeychainStore(keychainService: accountsKeychainService),
                httpClient: httpClient
            ),
            httpClient: httpClient,
            streamRuntime: StreamRuntime()
        )
        return .init(
            accountService: accountService,
            libraryCache: .init(directory: savedLibrariesDirectory),
            settingsViewModel: .init(
                preferences: preferences,
                controllerHub: controllers,
                streamPlatform: streamPlatform,
                networkPath: network
            ),
            streamDependencies: .init(
                preferences: preferences,
                controllerHub: controllers,
                streamPlatform: streamPlatform,
                networkPath: network
            )
        )
    }

    private var bundleID: String {
        Bundle.main.bundleIdentifier ?? "Starfold"
    }

    private var microsoftClientID: String {
        Bundle.main.infoDictionary?["StarfoldMicrosoftClientID"] as? String ?? ""
    }

    private var savedLibrariesDirectory: URL {
        .cachesDirectory.appending(path: "SavedLibraries", directoryHint: .isDirectory)
    }
}
