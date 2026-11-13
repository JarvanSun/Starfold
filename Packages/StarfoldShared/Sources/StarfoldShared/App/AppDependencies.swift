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
        let http = HTTPClient()
        let preferences = Preferences(defaults: .standard)
        let controllers = ControllerHub(routing: streamPlatform.controllerRouting)
        let accountsKeychainService = "\(bundleID).accounts"
        let accountService = LiveAccountService(
            store: .init(
                microsoftClientID: microsoftClientID,
                secrets: KeychainStore(service: accountsKeychainService),
                http: http
            ),
            http: http,
            streamRuntime: StreamRuntime()
        )
        return .init(
            accountService: accountService,
            cache: .init(directory: savedLibrariesDirectory),
            settings: .init(
                preferences: preferences,
                controllers: controllers,
                picture: streamPlatform.picture
            ),
            streamDependencies: .init(
                preferences: preferences,
                controllers: controllers,
                picture: streamPlatform.picture,
                overlays: streamPlatform.overlays
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
