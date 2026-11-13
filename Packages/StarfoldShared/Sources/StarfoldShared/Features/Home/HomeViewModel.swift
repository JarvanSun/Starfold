//
//  HomeViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import ImageIO
import Observation
import StreamKit
import UniformTypeIdentifiers
import XboxKit
import os

@Observable
public final class HomeViewModel {
    public var powerProblem: PowerProblem?

    var onSignInRequired: () -> Void = {}
    var onPlay: (StreamTarget) -> Void = { _ in }
    var onRefreshAccount: () async -> Void = {}

    public private(set) var consoles: [Console] = []

    private(set) var consolesState: LoadState = .idle
    private(set) var pendingPowerCommands: Set<String> = []
    private(set) var nowPlaying: ConsoleActivity?
    private(set) var lastPlayedHere: [String: ConsoleActivity] = [:]
    private(set) var lastFrames: [String: CGImage] = [:]

    private let accountID: String
    private let service: ConsoleService
    private let cache: LibraryCache
    private let clock: any Clock<Duration>
    private let log = Logger(category: .library)

    private var lastConsolesRefresh: (any InstantProtocol<Duration>)?

    public var isPowerProblemPresented: Bool {
        get { powerProblem != nil }
        set { powerProblem = newValue ? powerProblem : nil }
    }

    public var powerProblemTitle: String {
        powerProblem?.title ?? ""
    }

    public var firstConsole: Console? {
        consoles.first
    }

    public var otherConsoles: [Console] {
        .init(consoles.dropFirst())
    }

    public var consolesContent: ConsolesContent {
        switch (consolesState, consoles.isEmpty) {
        case (_, false): .consoles
        case (.idle, true), (.loading, true): .loading
        case (.failed(let message), true): .failed(message)
        case (.loaded, true): .empty
        }
    }

    public init(
        accountID: String,
        service: ConsoleService,
        cache: LibraryCache,
        clock: some Clock<Duration>
    ) {
        self.accountID = accountID
        self.service = service
        self.cache = cache
        self.clock = clock

        if let snapshot = cache.homeSnapshot(for: accountID) {
            restore(snapshot)
        }

        restoreLastFrames()
    }

    public func refreshAccount() async {
        await onRefreshAccount()
    }

    public func refresh() async {
        await refreshConsoles()

        await refreshConsoleActivity()
    }

    public func refreshConsoles() async {
        lastConsolesRefresh = clock.now
        consolesState = .loading

        do {
            let found = try await service.consoles()
            guard !Task.isCancelled else { return }

            consoles = found.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            consolesState = .loaded

            saveSnapshot()
            log.info(
                "Consoles loaded: \(found.map { $0.powerState.rawValue }.joined(separator: ", "), privacy: .public)"
            )
        } catch {
            recordFailure(error)
        }
    }

    func refreshConsoleActivity() async {
        do {
            let playing = try await service.activity()
            guard !Task.isCancelled else { return }

            nowPlaying = playing

            rememberOnConsoleThatIsOn(playing)

            saveSnapshot()
            log.info("Console activity: playing \(playing?.name ?? "nothing", privacy: .public)")
        } catch {
            log.error("Console activity failed: \(String(describing: error), privacy: .public)")
        }
    }

    func keepConsolesFresh(
        every interval: Duration = .seconds(30),
        refreshingIfOlderThan stale: Duration = .seconds(10)
    ) async {
        var threshold = stale

        while !Task.isCancelled {
            let age = consoleListAge
            let isListFresh = age < threshold

            switch isListFresh {
            case true: try? await clock.sleep(for: threshold - age)
            case false: await refreshConsoles()
            }

            threshold = interval
        }
    }

    public func play(_ console: Console) {
        onPlay(.console(id: console.id, name: console.name))
    }

    public func togglePower(of console: Console) async {
        guard case .command(let command) = powerControl(for: console) else { return }

        await send(command, to: console)
    }

    func send(_ command: XboxLiveClient.PowerCommand, to console: Console) async {
        pendingPowerCommands.insert(console.id)
        defer { pendingPowerCommands.remove(console.id) }

        do {
            try await service.send(command, to: console.id)
            log.info(
                "\(command.rawValue, privacy: .public) accepted by \(console.id, privacy: .public)"
            )
        } catch {
            reportPowerCommandFailure(error, for: console)
        }
    }

    func recordLastFrame(_ image: CGImage, console consoleID: String) {
        lastFrames[consoleID] = image

        guard let jpeg = jpegData(of: image) else { return }

        cache.saveLastFrame(jpeg, console: consoleID, for: accountID)
    }

    func console(id: String) -> Console? {
        consoles.first { $0.id == id }
    }

    public func activity(for console: Console) -> ConsoleActivity? {
        let isTheConsoleThatIsOn = console.powerState == .on && consoleThatIsOn?.id == console.id

        switch (nowPlaying, isTheConsoleThatIsOn) {
        case (let nowPlaying?, true): return nowPlaying
        default: return lastPlayedHere[console.id]
        }
    }

    public func cover(for console: Console) -> ConsoleCover {
        .init(activity: activity(for: console), lastFrame: lastFrames[console.id])
    }

    public func status(of console: Console) -> ConsoleStatus {
        .init(console: console)
    }

    public func powerControl(for console: Console) -> ConsolePowerControl {
        let isSending = pendingPowerCommands.contains(console.id)

        switch (ConsoleStatus(console: console), isSending) {
        case (.unreachable, _): return .unavailable
        case (.on, true): return .sending(.turnOff)
        case (.on, false): return .command(.turnOff)
        case (.standby, true): return .sending(.wakeUp)
        case (.standby, false): return .command(.wakeUp)
        }
    }
}

// MARK: - Private

private extension HomeViewModel {
    var consoleThatIsOn: Console? {
        consoles.first { $0.powerState == .on }
    }

    var consoleListAge: Duration {
        guard let lastConsolesRefresh else { return .zero }

        return age(of: lastConsolesRefresh)
    }

    func restore(_ snapshot: HomeSnapshot) {
        consoles = snapshot.consoles
        consolesState = .loaded
        lastPlayedHere = snapshot.lastPlayedHere
    }

    func saveSnapshot() {
        cache.save(HomeSnapshot(consoles: consoles, lastPlayedHere: lastPlayedHere), for: accountID)
    }

    func restoreLastFrames() {
        for (consoleID, data) in cache.lastFrames(for: accountID) {
            guard
                let source = CGImageSourceCreateWithData(data as CFData, nil),
                let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else {
                continue
            }

            lastFrames[consoleID] = image
        }
    }

    func jpegData(of image: CGImage) -> Data? {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(
                data,
                UTType.jpeg.identifier as CFString,
                1,
                nil
            )
        else {
            return nil
        }

        let lastFrameJPEGQuality = 0.8

        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: lastFrameJPEGQuality] as CFDictionary
        )

        let isFinalized = CGImageDestinationFinalize(destination)
        return isFinalized ? data as Data : nil
    }

    func rememberOnConsoleThatIsOn(_ activity: ConsoleActivity?) {
        guard var activity, let console = consoleThatIsOn else { return }

        activity.kind = .lastPlayedHere
        lastPlayedHere[console.id] = activity
    }

    func age<Instant: InstantProtocol<Duration>>(of instant: Instant) -> Duration {
        guard let now = clock.now as? Instant else { return .zero }

        return instant.duration(to: now)
    }

    func reportPowerCommandFailure(_ error: Error, for console: Console) {
        switch error {
        case XboxAccountError.signInRequired: onSignInRequired()
        default: powerProblem = .init(consoleName: console.name)
        }

        log.error("Power command failed: \(String(describing: error), privacy: .public)")
    }

    func recordFailure(_ error: Error) {
        if case XboxAccountError.signInRequired = error {
            onSignInRequired()
        }

        log.error("Consoles failed: \(String(describing: error), privacy: .public)")

        consolesState = .failed(error.localizedDescription)
    }
}
