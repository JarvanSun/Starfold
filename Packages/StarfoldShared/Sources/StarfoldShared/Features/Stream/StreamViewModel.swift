//
//  StreamViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

import AVFoundation
import Foundation
import Observation
import QuartzCore
import StreamKit
import XboxKit
import os

@Observable
public final class StreamViewModel {
    public let target: StreamTarget
    public let backdrop: StreamBackdrop
    public let renderer: StreamRenderer?
    public let dialogs = SystemDialogsViewModel()

    public var onStop: () -> Void = {}
    public var onEnd: () -> Void = {}
    var onSignInRequired: () -> Void = {}
    var onRestart: () async -> Void = {}

    public private(set) var phase: StreamPhase = .provisioning
    public private(set) var hasFirstFrame = false
    public private(set) var areControlsRevealed = true
    public private(set) var isMenuOpen = false

    private(set) var statistics = StreamStatistics()
    private(set) var startedSettings: StreamSettings?
    private(set) var quality: StreamQuality?
    private(set) var isResolutionLowered = false

    private let qualityOverride: StreamQuality?
    private let service: StreamService
    private let dependencies: StreamDependencies
    private let log = Logger(category: .stream)

    private var connection: StreamConnection?
    private var connectTask: Task<Void, Never>?
    private var updatesTask: Task<Void, Never>?
    private var runTask: Task<Void, Never>?
    private var restartTask: Task<Void, Never>?
    private var hideControlsTask: Task<Void, Never>?
    private var settingsTask: Task<Void, Never>?
    private var appliedSettings: StreamPlaybackSettings?
    private var keyboard = KeyboardGamepad()
    private var hasLoggedFirstRumble = false
    private var statisticsTicks = 0
    private var isInForeground = true
    private var startedAt = ContinuousClock.now

    public var sharpeningLevel: SharpeningLevel {
        get { .init(strength: preferences.sharpening) }
        set { preferences.sharpening = newValue.rawValue }
    }

    public var sharpeningLevels: [SharpeningLevel] {
        SharpeningLevel.allCases
    }

    public var isStreaming: Bool {
        phase == .streaming
    }

    public var isWaitingForPicture: Bool {
        !isStreaming || !hasFirstFrame
    }

    public var status: StreamStatus {
        switch phase {
        case .ended(let reason): .ended(reason, advice: .init(endReason: reason))
        case .queued(let wait): .queued(estimatedWait: wait.map(queueEstimate(_:)))
        case .provisioning, .connecting, .streaming: .connecting
        }
    }

    private func queueEstimate(_ wait: Duration) -> String {
        let shortestQueueEstimate: Duration = .seconds(60)

        return max(wait, shortestQueueEstimate).formatted(.units(allowed: [.minutes], width: .wide))
    }

    public var isShowingControls: Bool {
        isStreaming && areControlsRevealed
    }

    public var canOpenMenu: Bool {
        isStreaming && dialogs.queue.isEmpty
    }

    public var isPlayable: Bool {
        !isWaitingForPicture && dialogs.queue.isEmpty && hasInput
    }

    public var needsController: Bool {
        isStreaming && !hasInput
    }

    private var hasInput: Bool {
        dependencies.touch != nil || !controllers.connected.isEmpty
    }

    public var isRoutingInputToGame: Bool {
        isPlayable && !isMenuOpen && isInForeground
    }

    public var isXboxButtonTakenBySystem: Bool {
        controllers.xboxButton.owner == .system
    }

    public var isShowingStatistics: Bool {
        isStreaming && preferences.shouldShowStatistics
    }

    public var statisticsReadout: StatisticsReadout {
        .init(
            statistics: statistics,
            kinds: dependencies.overlays.statisticsRows,
            usesAutomaticQuality: usesAutomaticQuality,
            loweredFrom: isResolutionLowered ? quality : nil
        )
    }

    public var needsRestartForSettings: Bool {
        guard let startedSettings, !hasEnded else { return false }

        return StreamSettings(target: target, preferences: preferences) != startedSettings
    }

    var hasEnded: Bool {
        switch phase {
        case .ended: true
        default: false
        }
    }

    var usesAutomaticQuality: Bool {
        qualityOverride == nil && startedSettings?.choice == .automatic
    }

    private var preferences: Preferences {
        dependencies.preferences
    }

    private var controllers: ControllerHub {
        dependencies.controllers
    }

    private var playbackSettings: StreamPlaybackSettings {
        .init(preferences: preferences, picture: dependencies.picture)
    }

    public init(
        target: StreamTarget,
        backdrop: StreamBackdrop,
        qualityOverride: StreamQuality?,
        service: StreamService,
        dependencies: StreamDependencies
    ) {
        self.target = target
        self.backdrop = backdrop
        self.qualityOverride = qualityOverride
        self.service = service
        self.dependencies = dependencies
        renderer = StreamRenderer(keepsLastFrame: dependencies.picture.shouldKeepLastFrame)

        apply(playbackSettings)

        observeSettings()
    }

    private func observeSettings() {
        settingsTask = Task { [weak self] in
            for await settings in Observations({ self?.playbackSettings }) {
                guard let self, let settings, !hasEnded else { return }

                apply(settings)
            }
        }
    }

    private func apply(_ settings: StreamPlaybackSettings) {
        guard settings != appliedSettings else { return }

        appliedSettings = settings

        service.setDirectStereo(settings.isDirectStereo)

        guard let renderer else { return }

        renderer.systemVideo.setPacing(settings.pacing)
        renderer.systemVideo.layer.videoGravity = settings.videoGravity

        if let dynamicRange = settings.dynamicRange {
            renderer.systemVideo.layer.preferredDynamicRange = dynamicRange
        }

        if let enhancements = settings.enhancements {
            renderer.setEnhancements(enhancements)
        }
    }

    public func start() {
        guard renderer != nil else {
            fail(String(localized: "stream.failure.metalUnavailable", bundle: .module))

            return
        }

        let settings = StreamSettings(target: target, preferences: preferences)
        startedSettings = settings

        let quality = networkQuality(for: qualityOverride ?? settings.choice.requestedQuality)
        self.quality = quality

        let options = StreamOptions(
            quality: quality,
            maxBitrateKbps: settings.maxBitrateKbps,
            gameLocale: preferences.effectiveGameLanguage,
            clientAppInstallID: preferences.clientAppInstallID
        )

        startedAt = .now
        connectTask = Task { await connect(with: options) }
    }

    private func networkQuality(for requested: StreamQuality) -> StreamQuality {
        switch dependencies.network.isOnCellular {
        case true: requested.capped(at: preferences.cellularQuality)
        case false: requested
        }
    }

    private func connect(with options: StreamOptions) async {
        do {
            let connection = try await service.connect(to: target, options: options)
            guard !Task.isCancelled, let renderer else { return }

            run(connection, on: renderer)
        } catch XboxAccountError.signInRequired {
            onSignInRequired()

            fail(String(localized: "stream.failure.signInExpired", bundle: .module))
        } catch {
            guard !Task.isCancelled else { return }

            fail(error.localizedDescription)
        }
    }

    private func run(_ connection: StreamConnection, on renderer: StreamRenderer) {
        self.connection = connection

        renderer.notifyFirstFrame { [weak self] in
            Task { @MainActor in self?.didPresentFirstFrame() }
        }

        updatesTask = Task { [weak self] in
            for await update in connection.updates {
                self?.apply(update)
            }
        }

        dialogs.attach(connection)

        wireInput(to: connection)

        runTask = Task { await connection.start(sink: renderer) }
    }

    private func didPresentFirstFrame() {
        guard !hasFirstFrame else { return }

        hasFirstFrame = true
        log.info(
            "Startup first frame on screen +\((ContinuousClock.now - self.startedAt).formatted(.units(allowed: [.milliseconds])), privacy: .public)"
        )
    }

    private func apply(_ update: StreamUpdate) {
        switch update {
        case .phase(let phase): apply(phase)
        case .statistics(let statistics): apply(statistics)
        case .dialog(let request): dialogs.add(request)
        case .dialogDismissed(let id): dialogs.remove(id: id)
        case .vibration(let effect): play(effect)
        case .videoSize: break
        }
    }

    private func play(_ effect: VibrationEffect) {
        logFirstRumble(effect)

        guard controllers.isRoutingToGame, preferences.isRumbleEnabled else { return }

        controllers.playRumble(effect)
    }

    private func logFirstRumble(_ effect: VibrationEffect) {
        guard !hasLoggedFirstRumble else { return }

        hasLoggedFirstRumble = true
        log.info(
            "Host sent rumble for pad \(effect.gamepadIndex): \(effect.leftMotor) / \(effect.rightMotor), enabled \(self.preferences.isRumbleEnabled)"
        )
    }

    private func apply(_ phase: StreamPhase) {
        self.phase = phase

        switch phase {
        case .streaming: revealControls()
        case .ended: finishAfterEnd()
        case .provisioning, .queued, .connecting: break
        }
    }

    private func finishAfterEnd() {
        hideControlsTask?.cancel()
        settingsTask?.cancel()

        controllers.stopRumble()

        onEnd()
    }

    private func apply(_ statistics: StreamStatistics) {
        var statistics = statistics
        statistics.displayMs = renderer?.displayLatencyMs
        statistics.upscaledTo = renderer?.upscaledTo
        statistics.isToneMapped = renderer?.isToneMapping ?? false
        self.statistics = statistics

        logPacing()

        noteResolution(statistics.resolution)
    }

    private func logPacing() {
        statisticsTicks += 1

        let pacingLogInterval = 5

        guard statisticsTicks.isMultiple(of: pacingLogInterval), let renderer else { return }

        let pacing = renderer.systemVideo.takeCounters()
        log.info(
            "Pacing 5s: \(String(describing: self.preferences.pacingMode), privacy: .public) \(Int(pacing.pacingDelayMs.rounded())) ms, late \(pacing.lateFrames) frames"
        )
    }

    private func noteResolution(_ received: CGSize?) {
        guard let received, let quality else { return }

        isResolutionLowered = AdaptiveQuality(target: target)
            .isLoweredByHost(received: received, requested: quality)
    }

    private func wireInput(to connection: StreamConnection) {
        controllers.router.setDestination { slot, state in
            connection.setGamepad(slot, state: state)
        }
    }

    private func fail(_ message: String) {
        phase = .ended(.failed(message))
    }

    func stop() async {
        onStop()

        controllers.router.setDestination(nil)
        controllers.stopRumble()

        connectTask?.cancel()
        runTask?.cancel()
        hideControlsTask?.cancel()
        settingsTask?.cancel()

        if let connection {
            await connection.stop(reason: .userStopped)
        }

        updatesTask?.cancel()

        renderer?.clear()

        if !hasEnded {
            phase = .ended(.userStopped)
        }
    }

    public func tryAgain() {
        guard restartTask == nil else { return }

        restartTask = Task { await onRestart() }
    }

    public func revealControls() {
        areControlsRevealed = true

        hideControlsTask?.cancel()

        guard let delay = dependencies.overlays.controlsHideDelay else { return }

        hideControlsTask = Task { await hideControls(after: delay) }
    }

    private func hideControls(after delay: Duration) async {
        try? await Task.sleep(for: delay)

        guard !Task.isCancelled else { return }

        areControlsRevealed = false
    }

    public func openMenu() {
        guard canOpenMenu else { return }

        isMenuOpen = true
    }

    public func closeMenu() {
        isMenuOpen = false
    }

    public func moveToForeground(_ isInForeground: Bool) {
        self.isInForeground = isInForeground
    }

    public func openGuide() {
        guard let connection else { return }

        Task { await connection.pressGuide() }
    }

    public func openXboxButtonSettings() {
        controllers.xboxButton.openSettings()
    }

    public func requestKeyframe() {
        guard let connection else { return }

        Task { await connection.requestKeyframe() }
    }

    public func showNextPictureFit() {
        let fits = PictureFit.allCases
        guard let index = fits.firstIndex(of: preferences.pictureFit) else { return }

        preferences.pictureFit = fits[(index + 1) % fits.count]
    }

    @discardableResult
    public func handleKey(_ keyCode: UInt16, isDown: Bool) -> Bool {
        guard preferences.isKeyboardControllerEnabled, isStreaming else { return false }

        let isHandled = keyboard.setKey(keyCode, isDown: isDown)

        if isHandled {
            controllers.router.setKeyboard(keyboard.state)
        }

        return isHandled
    }

    public func releaseKeyboard() {
        keyboard.releaseAll()
        controllers.router.setKeyboard(keyboard.state)
    }

    public func statisticsReport(device: String) -> String {
        StatisticsReport(
            statistics: statistics,
            appName: AppInfo().displayName,
            appVersion: AppInfo().version,
            device: device
        )
        .text
    }
}
