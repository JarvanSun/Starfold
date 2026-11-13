//
//  PreviewObjectPool.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation
import StarfoldShared
import StreamKit
import XboxKit

enum PreviewObjectPool {
    static func appViewModel(signedIn: Bool) -> AppViewModel {
        let app = appViewModel(accounts: signedIn ? [account(streamPhase: .streaming)] : [])

        Task { await app.restore() }

        return app
    }

    static func appViewModel(streamPhase: StreamPhase) -> AppViewModel {
        let app = appViewModel(accounts: [account(streamPhase: streamPhase)])
        let console = consoles[0]

        Task {
            await app.restore()

            await app.play(.console(id: console.id, name: console.name))
        }

        return app
    }

    static var settingsViewModel: SettingsViewModel {
        settingsViewModel(preferences: preferences, controllers: controllers)
    }

    static var failedLoadState: LoadState {
        .failed("The network connection was lost.")
    }
}

extension PreviewObjectPool {
    static var preferences: Preferences {
        let userDefaults = UserDefaults(suiteName: "Starfold.previews")!

        return .init(defaults: userDefaults)
    }

    static var controllers: ControllerHub {
        .init(routing: .direct)
    }

    static var streamDependencies: StreamDependencies {
        streamDependencies(preferences: preferences, controllers: controllers)
    }

    static var libraryCache: LibraryCache {
        .init(directory: .temporaryDirectory.appending(path: "Previews/\(UUID().uuidString)"))
    }

    static func appViewModel(accountService: PreviewAccountService) -> AppViewModel {
        let preferences = Self.preferences
        let controllers = Self.controllers

        return .init(
            accountService: accountService,
            cache: libraryCache,
            settings: settingsViewModel(preferences: preferences, controllers: controllers),
            streamDependencies: streamDependencies(
                preferences: preferences,
                controllers: controllers
            )
        )
    }

    static func settingsViewModel(
        preferences: Preferences,
        controllers: ControllerHub
    ) -> SettingsViewModel {
        .init(preferences: preferences, controllers: controllers, picture: picture)
    }

    static func streamDependencies(
        preferences: Preferences,
        controllers: ControllerHub
    ) -> StreamDependencies {
        .init(
            preferences: preferences,
            controllers: controllers,
            picture: picture,
            overlays: streamOverlays
        )
    }

    static func account(streamPhase: StreamPhase) -> SignedInAccount {
        .init(
            summary: .init(id: profile.xuid, gamertag: profile.gamertag),
            consoles: consoleService(state: .loaded, consoles: consoles),
            cloudLibrary: cloudLibraryService(state: .loaded, games: cloudGames, access: .gamePass),
            streams: streamService(phase: streamPhase, dialogs: [])
        )
    }
}

private extension PreviewObjectPool {
    static var picture: PictureCapabilities {
        .init(
            canFit: true,
            canEnhance: true,
            shouldKeepLastFrame: false,
            isHDRDisplayAvailable: nil
        )
    }

    static func appViewModel(accounts: [SignedInAccount]) -> AppViewModel {
        appViewModel(
            accountService: PreviewAccountService(
                accounts: accounts,
                profile: profile,
                signInPhase: .waiting(deviceCodePrompt)
            )
        )
    }

}
#endif
