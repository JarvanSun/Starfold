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
    public let settingsViewModel: SettingsViewModel
    public var isSignInExpired = false

    public var onPlayRequest: ((StreamTarget) -> Void)?

    public private(set) var sessionState: SessionState = .restoring
    public private(set) var accounts: [AccountSummary] = []
    public private(set) var activeAccountID: String?
    public private(set) var profile: XboxProfile?
    public private(set) var homeViewModel: HomeViewModel?
    public private(set) var libraryViewModel: LibraryViewModel?
    public private(set) var streamViewModel: StreamViewModel?
    public private(set) var streamPresentationRequest = 0

    private let accountService: AccountService
    private let libraryCache: LibraryCache
    private let streamDependencies: StreamDependencies
    private let log = Logger(category: .app)

    private var signedInAccounts: [String: SignedInAccount] = [:]
    private var loadTask: Task<Void, Never>?
    private var isActive = false
    private var consoleRefreshTask: Task<Void, Never>?
    private var playTask: Task<Void, Never>?
    private weak var streamHomeViewModel: HomeViewModel?

    public var signedInGamertag: String? {
        profile?.gamertag ?? accounts.first { $0.id == activeAccountID }?.gamertag
    }

    public var controllerHub: ControllerHub {
        streamDependencies.controllerHub
    }

    var needsStreamRestartForSettings: Bool {
        streamViewModel?.needsRestartForSettings ?? false
    }

    private var preferences: Preferences {
        streamDependencies.preferences
    }

    public init(
        accountService: AccountService,
        libraryCache: LibraryCache,
        settingsViewModel: SettingsViewModel,
        streamDependencies: StreamDependencies
    ) {
        self.accountService = accountService
        self.libraryCache = libraryCache
        self.settingsViewModel = settingsViewModel
        self.streamDependencies = streamDependencies

        settingsViewModel.sessionController = self
    }

    public func restore() async {
        let restored = await accountService.restoreAccounts()
        signedInAccounts = .init(uniqueKeysWithValues: restored.map { ($0.id, $0) })
        accounts = restored.map(\.summary)

        let preferred = preferences.lastAccountID.flatMap { signedInAccounts[$0] } ?? restored.first
        activateOrShowWelcome(preferred)
    }

    private func activateOrShowWelcome(_ account: SignedInAccount?) {
        switch account {
        case let account?: activate(account)
        case nil: sessionState = .signedOut
        }
    }

    private func activate(_ account: SignedInAccount) {
        activeAccountID = account.id
        preferences.lastAccountID = account.id
        sessionState = .signedIn
        profile = nil

        let homeViewModel = makeHomeViewModel(for: account)
        let libraryViewModel = makeLibraryViewModel(for: account)
        self.homeViewModel = homeViewModel
        self.libraryViewModel = libraryViewModel

        loadInBackground(account, homeViewModel: homeViewModel, libraryViewModel: libraryViewModel)

        restartConsoleRefresh()
    }

    private func makeHomeViewModel(for account: SignedInAccount) -> HomeViewModel {
        let homeViewModel = HomeViewModel(
            accountID: account.id,
            consoleService: account.consoleService,
            libraryCache: libraryCache,
            clock: ContinuousClock()
        )
        homeViewModel.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        homeViewModel.onPlay = { [weak self] in self?.requestPlay($0) }
        homeViewModel.onRefreshAccount = { [weak self] in await self?.refresh() }
        return homeViewModel
    }

    private func requestPlay(_ target: StreamTarget) {
        switch onPlayRequest {
        case let onPlayRequest?: onPlayRequest(target)
        case nil: playInBackground(target)
        }
    }

    private func playInBackground(_ target: StreamTarget) {
        playTask?.cancel()
        playTask = Task { await play(target) }
    }

    private func makeLibraryViewModel(for account: SignedInAccount) -> LibraryViewModel {
        let libraryViewModel = LibraryViewModel(
            accountID: account.id,
            cloudLibraryService: account.cloudLibraryService,
            preferences: preferences,
            libraryCache: libraryCache
        )
        libraryViewModel.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        libraryViewModel.onPlay = { [weak self] in self?.requestPlay($0) }
        return libraryViewModel
    }

    private func loadInBackground(
        _ account: SignedInAccount,
        homeViewModel: HomeViewModel,
        libraryViewModel: LibraryViewModel
    ) {
        loadTask?.cancel()
        loadTask = Task {
            async let profileLoad: Void = loadProfile(account)
            async let homeLoad: Void = homeViewModel.refresh()
            async let libraryLoad: Void = libraryViewModel.refresh()
            _ = await (profileLoad, homeLoad, libraryLoad)
        }
    }

    private func loadProfile(_ account: SignedInAccount) async {
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

    private func updateGamertag(of account: SignedInAccount, to gamertag: String) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }

        accounts[index].gamertag = gamertag
    }

    private func restartConsoleRefresh() {
        consoleRefreshTask?.cancel()
        consoleRefreshTask = nil

        guard isActive, let homeViewModel else { return }

        consoleRefreshTask = Task { await homeViewModel.keepConsolesFresh() }
    }

    public func makeSignInViewModel() -> SignInViewModel {
        .init(signInService: self, clock: ContinuousClock())
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

        libraryCache.removeLastFrames(for: id)

        signedInAccounts[id] = nil
        accounts.removeAll { $0.id == id }

        activeAccountID = nil
        profile = nil
        homeViewModel = nil
        libraryViewModel = nil
        preferences.lastAccountID = nil

        activateOrShowWelcome(accounts.first.flatMap { signedInAccounts[$0.id] })
    }

    public func refresh() async {
        guard let homeViewModel, let libraryViewModel else { return }

        async let homeRefresh: Void = homeViewModel.refresh()
        async let libraryRefresh: Void = libraryViewModel.refresh()
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

    private func startStream(_ target: StreamTarget) async {
        guard let account = activeAccount else { return }

        if let streamViewModel {
            keepLastFrame(of: streamViewModel)

            await streamViewModel.stop(.userStopped)
        }

        let streamViewModel = StreamViewModel(
            target: target,
            backdrop: backdrop(for: target),
            qualityOverride: qualityOverride(for: target),
            streamService: account.streamService,
            streamDependencies: streamDependencies
        )
        streamViewModel.onSignInRequired = { [weak self] in self?.isSignInExpired = true }
        streamViewModel.onRestart = { [weak self] in await self?.restartStream() }
        self.streamViewModel = streamViewModel
        streamHomeViewModel = homeViewModel

        streamViewModel.start()
    }

    private func keepLastFrame(of streamViewModel: StreamViewModel) {
        guard
            case .console(let consoleID, _) = streamViewModel.target,
            streamViewModel.hasFirstFrame,
            let image = streamViewModel.renderer?.lastFrameImage()
        else {
            return
        }

        streamHomeViewModel?.recordLastFrame(image, console: consoleID)
    }

    private func backdrop(for target: StreamTarget) -> StreamBackdrop {
        let fallbackConsoleType = "XboxSeriesX"

        return switch target {
        case .console(let id, _):
            .console(type: homeViewModel?.console(id: id)?.consoleType ?? fallbackConsoleType)
        case .cloud(let titleID, _):
            .game(
                heroImage: libraryViewModel?.game(id: titleID)?.product
                    .flatMap { $0.heroImage ?? $0.titledHeroImage }
            )
        }
    }

    private func qualityOverride(for target: StreamTarget) -> StreamQuality? {
        let choice = StreamSettings(target: target, preferences: preferences).choice
        let allowed = AdaptiveQuality(target: target)
            .requestedQuality(for: choice, hasGamePass: libraryViewModel?.cloudAccess == .gamePass)
        return allowed != choice.requestedQuality ? allowed : nil
    }

    private func requestStreamPresentation() {
        guard streamViewModel != nil else { return }

        streamPresentationRequest += 1
    }

    public func restartStream() async {
        guard let target = streamViewModel?.target else { return }

        await startStream(target)
    }

    private var activeAccount: SignedInAccount? {
        activeAccountID.flatMap { signedInAccounts[$0] }
    }

    public func endStream() async {
        guard let ending = streamViewModel else { return }

        keepLastFrame(of: ending)

        await ending.stop(.userStopped)

        if streamViewModel === ending {
            streamViewModel = nil
        }
    }

    public func endStreamWhileAway() async {
        guard let streamViewModel else { return }

        keepLastFrame(of: streamViewModel)

        await streamViewModel.stop(.leftApp)
    }

    func needsNewStream(for target: StreamTarget) -> Bool {
        guard let streamViewModel, streamViewModel.target == target else { return true }

        return streamViewModel.hasEnded
    }
}
