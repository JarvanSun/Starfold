//
//  AppHarness.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

@testable import StarfoldShared

struct AppHarness {
    let accountService = AccountServiceStub()
    let defaults: UserDefaults
    let cacheDirectory: URL
    let appViewModel: AppViewModel

    var preferences: Preferences {
        .init(defaults: defaults)
    }

    var cache: LibraryCache {
        .init(directory: cacheDirectory)
    }

    init() {
        let suiteName = UserDefaults.dummySuiteName()
        self.init(
            defaults: .init(suiteName: suiteName)!,
            cacheDirectory: FileManager.default.temporaryDirectory.appending(path: suiteName)
        )
    }

    init(relaunching other: AppHarness) {
        self.init(defaults: other.defaults, cacheDirectory: other.cacheDirectory)
    }

    private init(defaults: UserDefaults, cacheDirectory: URL) {
        let preferences = Preferences(defaults: defaults)
        let dependencies = StreamDependencies.dummy(preferences: preferences)
        self.defaults = defaults
        self.cacheDirectory = cacheDirectory
        appViewModel = AppViewModel(
            accountService: accountService,
            libraryCache: .init(directory: cacheDirectory),
            settingsViewModel: .init(
                preferences: preferences,
                controllerHub: dependencies.controllerHub,
                streamPlatform: dependencies.streamPlatform,
                networkPath: dependencies.networkPath
            ),
            streamDependencies: dependencies
        )
    }

    func home(
        for accountID: String,
        service: ConsoleService,
        clock: some Clock<Duration> = ContinuousClock()
    ) -> HomeViewModel {
        .init(accountID: accountID, consoleService: service, libraryCache: cache, clock: clock)
    }

    func library(for accountID: String, service: CloudLibraryService) -> LibraryViewModel {
        .init(
            accountID: accountID,
            cloudLibraryService: service,
            preferences: preferences,
            libraryCache: cache
        )
    }
}
