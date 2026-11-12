//
//  AppViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Observation
import StreamKit
import XboxKit
import os

@Observable
public final class AppViewModel: SigningIn, SessionControlling {
    private let accountService: AccountService
    private let cache: LibraryCache
    public let settings: SettingsViewModel
    private let streamDependencies: StreamDependencies

    public var isSignInExpired = false
    public var onPlayRequest: ((StreamTarget) -> Void)?
    public private(set) var sessionState: SessionState = .restoring
    public private(set) var accounts: [AccountSummary] = []
    public private(set) var activeAccountID: String?
    public private(set) var profile: XboxProfile?
    public private(set) var home: HomeViewModel?
    public private(set) var library: LibraryViewModel?
    public private(set) var stream: StreamViewModel?
    public private(set) var streamPresentationRequest = 0
    private let log = Logger(category: .app)
    private var signedInAccounts: [String: SignedInAccount] = [:]
    private var loadTask: Task<Void, Never>?
    private var isActive = false
    private var consoleRefreshTask: Task<Void, Never>?
    private var playTask: Task<Void, Never>?
    private weak var streamHome: HomeViewModel?

    public var signedInGamertag: String? {
        profile?.gamertag ?? accounts.first { $0.id == activeAccountID }?.gamertag
    }

    public var controllers: ControllerHub {
        streamDependencies.controllers
    }

    var needsStreamRestartForSettings: Bool {
        stream?.needsRestartForSettings ?? false
    }

    public init(
        accountService: AccountService,
        cache: LibraryCache,
        settings: SettingsViewModel,
        streamDependencies: StreamDependencies
    ) {
        self.accountService = accountService
        self.cache = cache
        self.settings = settings
        self.streamDependencies = streamDependencies

        settings.session = self
    }

    public func restore() async {
        let restored = await accountService.restoreAccounts()
        signedInAccounts = .init(uniqueKeysWithValues: restored.map { ($0.id, $0) })
        accounts = restored.map(\.summary)

        let preferred = preferences.lastAccountID.flatMap { signedInAccounts[$0] } ?? restored.first
        activateOrShowWelcome(preferred)
    }

    public func makeSignInViewModel() -> SignInViewModel {
        .init(service: self, clock: ContinuousClock())
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        try await accountService.beginSignIn()
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void = {}
    ) async throws {
        let account = try await accountService.completeSignIn(prompt, onAuthorized: onAuthorized)
        signedInAccounts[account.id] = account

        accounts.removeAll { $0.id == account.id }
        accounts.append(account.summary)

        isSignInExpired = false

        activate(account)
    }

    public func switchAccount(to id: String) async {
        guard let account = signedInAccounts[id], id != activeAccountID else { return }

        activate(account)
    }

    public func signOut() {
        guard let id = activeAccountID, let account = signedInAccounts[id] else { return }

        try? accountService.signOut(account)

        cache.removeLastFrames(for: id)

        signedInAccounts[id] = nil
        accounts.removeAll { $0.id == id }

        activeAccountID = nil
        profile = nil
        home = nil
        library = nil
        preferences.lastAccountID = nil

        activateOrShowWelcome(accounts.first.flatMap { signedInAccounts[$0.id] })
    }

    public func refresh() async {
        guard let home, let library else { return }

        async let homeRefresh: Void = home.refresh()
        async let libraryRefresh: Void = library.refresh()
        _ = await (homeRefresh, libraryRefresh)
    }

    public func setActive(_ active: Bool) {
        guard active != isActive else { return }

        isActive = active

        restartConsoleRefresh()
    }

    public func play(_ target: StreamTarget) async {
        if needsNewStream(for: target) {
            await startStream(target)
        }

        requestStreamPresentation()
    }

    public func restartStream() async {
        guard let target = stream?.target else { return }

        await startStream(target)
    }

    public func endStream() async {
        guard let ending = stream else { return }

        keepLastFrame(of: ending)

        await ending.stop()

        if stream === ending {
            stream = nil
        }
    }

    func needsNewStream(for target: StreamTarget) -> Bool {
        guard let stream, stream.target == target else { return true }

        return stream.hasEnded
    }
}

// MARK: - Private

private extension AppViewModel {
    var fallbackConsoleType: String {
        "XboxSeriesX"
    }

    var preferences: Preferences {
        streamDependencies.preferences
    }

    var activeAccount: SignedInAccount? {
        activeAccountID.flatMap { signedInAccounts[$0] }
    }

    func activateOrShowWelcome(_ account: SignedInAccount?) {
        switch account {
        case let account?: activate(account)
        case nil: sessionState = .signedOut
        }
    }

    func activate(_ account: SignedInAccount) {
        activeAccountID = account.id
        preferences.lastAccountID = account.id
        sessionState = .signedIn
        profile = nil

        let home = makeHome(for: account)
        let library = makeLibrary(for: account)
        self.home = home
        self.library = library

        loadInBackground(account, home: home, library: library)

        restartConsoleRefresh()
    }

    func makeHome(for account: SignedInAccount) -> HomeViewModel {
        let home = HomeViewModel(
            accountID: account.id,
            service: account.consoles,
            cache: cache,
            clock: ContinuousClock()
        )
        home.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        home.onPlay = { [weak self] in self?.requestPlay($0) }
        home.onRefreshAccount = { [weak self] in await self?.refresh() }
        return home
    }

    func makeLibrary(for account: SignedInAccount) -> LibraryViewModel {
        let library = LibraryViewModel(
            accountID: account.id,
            service: account.cloudLibrary,
            preferences: preferences,
            cache: cache
        )
        library.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        library.onPlay = { [weak self] in self?.requestPlay($0) }
        return library
    }

    func requestPlay(_ target: StreamTarget) {
        switch onPlayRequest {
        case let onPlayRequest?: onPlayRequest(target)
        case nil: playInBackground(target)
        }
    }

    func playInBackground(_ target: StreamTarget) {
        playTask?.cancel()
        playTask = Task { await play(target) }
    }

    func loadInBackground(
        _ account: SignedInAccount,
        home: HomeViewModel,
        library: LibraryViewModel
    ) {
        loadTask?.cancel()
        loadTask = Task {
            async let profileLoad: Void = loadProfile(account)
            async let homeLoad: Void = home.refresh()
            async let libraryLoad: Void = library.refresh()
            _ = await (profileLoad, homeLoad, libraryLoad)
        }
    }

    func loadProfile(_ account: SignedInAccount) async {
        do {
            let profile = try await accountService.profile(of: account)
            guard !Task.isCancelled else { return }

            self.profile = profile

            updateGamertag(of: account, to: profile.gamertag)
        } catch XboxAccountError.signInRequired {
            isSignInExpired = true
        } catch {
            log.error("Profile failed: \(String(describing: error))")
        }
    }

    func updateGamertag(of account: SignedInAccount, to gamertag: String) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }

        accounts[index].gamertag = gamertag
    }

    func restartConsoleRefresh() {
        consoleRefreshTask?.cancel()
        consoleRefreshTask = nil

        guard isActive, let home else { return }

        consoleRefreshTask = Task { await home.keepConsolesFresh() }
    }

    func startStream(_ target: StreamTarget) async {
        guard let account = activeAccount else { return }

        if let stream {
            keepLastFrame(of: stream)

            await stream.stop()
        }

        let stream = StreamViewModel(
            target: target,
            backdrop: backdrop(for: target),
            qualityOverride: qualityOverride(for: target),
            service: account.streams,
            dependencies: streamDependencies
        )
        stream.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        stream.onRestart = { [weak self] in await self?.restartStream() }
        self.stream = stream
        streamHome = home

        stream.start()
    }

    func requestStreamPresentation() {
        guard stream != nil else { return }

        streamPresentationRequest += 1
    }

    func backdrop(for target: StreamTarget) -> StreamBackdrop {
        switch target {
        case .console(let id, _):
            .console(type: home?.console(id: id)?.consoleType ?? fallbackConsoleType)
        case .cloud(let titleID, _):
            .game(
                heroImage: library?.game(id: titleID)?.product
                    .flatMap { $0.heroImage ?? $0.titledHeroImage }
            )
        }
    }

    func qualityOverride(for target: StreamTarget) -> StreamQuality? {
        let choice = StreamSettings(target: target, preferences: preferences).choice
        let allowed = AdaptiveQuality(target: target)
            .requestedQuality(for: choice, hasGamePass: library?.cloudAccess == .gamePass)
        return allowed != choice.requestedQuality ? allowed : nil
    }

    func keepLastFrame(of stream: StreamViewModel) {
        guard
            case .console(let consoleID, _) = stream.target,
            stream.hasFirstFrame,
            let image = stream.renderer?.lastFrameImage()
        else {
            return
        }

        streamHome?.recordLastFrame(image, console: consoleID)
    }
}
