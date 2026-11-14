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
    public let systemDialogsViewModel = SystemDialogsViewModel()
    public let touchControlsViewModel: TouchControlsViewModel?

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
    private let streamService: StreamService
    private let streamDependencies: StreamDependencies
    private let log = Logger(category: .stream)

    private var streamConnection: StreamConnection?
    private var connectTask: Task<Void, Never>?
    private var updatesTask: Task<Void, Never>?
    private var runTask: Task<Void, Never>?
    private var restartTask: Task<Void, Never>?
    private var hideControlsTask: Task<Void, Never>?
    private var settingsTask: Task<Void, Never>?
    private var appliedSettings: StreamPlaybackSettings?
    private var keyboardGamepad = KeyboardGamepad()
    private var hasLoggedFirstRumble = false
    private var statisticsTicks = 0
    private var isInForeground = true
    private var touchBundleTasks: [String: Task<Void, Never>] = [:]
    private var touchBundleAttempts: [String: Int] = [:]
    private var touchBundleTitles: Set<String> = []
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
        isStreaming && systemDialogsViewModel.dialogQueue.isEmpty
    }

    public var isPlayable: Bool {
        !isWaitingForPicture && systemDialogsViewModel.dialogQueue.isEmpty && hasInput
    }

    public var needsController: Bool {
        isStreaming && !hasInput
    }

    private var hasInput: Bool {
        streamDependencies.touchPlatform != nil || !controllerHub.connectedControllers.isEmpty
    }

    public var isShowingMenuHandle: Bool {
        isStreaming && !isMenuOpen
            && (areControlsRevealed || touchControlsViewModel?.isShowing == true)
    }

    public var isShowingTouchControls: Bool {
        isStreaming && hasFirstFrame && !isMenuOpen && touchControlsViewModel?.isShowing == true
    }

    public var isRoutingInputToGame: Bool {
        isPlayable && !isMenuOpen && isInForeground
    }

    public var isXboxButtonTakenBySystem: Bool {
        controllerHub.xboxButton.owner == .system
    }

    public var isShowingStatistics: Bool {
        isStreaming && preferences.shouldShowStatistics
    }

    public var statisticsReadout: StatisticsReadout {
        .init(
            statistics: statistics,
            kinds: streamDependencies.overlays.statisticsRows,
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
        streamDependencies.preferences
    }

    private var controllerHub: ControllerHub {
        streamDependencies.controllerHub
    }

    private var playbackSettings: StreamPlaybackSettings {
        .init(
            preferences: preferences,
            picture: streamDependencies.pictureCapabilities,
            touch: streamDependencies.touchPlatform
        )
    }

    public init(
        target: StreamTarget,
        backdrop: StreamBackdrop,
        qualityOverride: StreamQuality?,
        streamService: StreamService,
        streamDependencies: StreamDependencies
    ) {
        self.target = target
        self.backdrop = backdrop
        self.qualityOverride = qualityOverride
        self.streamService = streamService
        self.streamDependencies = streamDependencies
        renderer = StreamRenderer(
            keepsLastFrame: streamDependencies.pictureCapabilities.shouldKeepLastFrame
        )
        touchControlsViewModel = streamDependencies.touchPlatform.map { _ in
            .init(
                controllerHub: streamDependencies.controllerHub,
                preferences: streamDependencies.preferences
            )
        }

        configure(for: playbackSettings)

        observeSettings()
    }

    private func observeSettings() {
        settingsTask = Task { [weak self] in
            for await settings in Observations({ self?.playbackSettings }) {
                guard let self, let settings, !hasEnded else { return }

                configure(for: settings)
            }
        }
    }

    private func configure(for settings: StreamPlaybackSettings) {
        guard settings != appliedSettings else { return }

        appliedSettings = settings

        streamService.setDirectStereo(settings.isDirectStereo)

        controllerHub.isDeviceRumbleEnabled = settings.isDeviceRumbleEnabled

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
            clientAppInstallID: preferences.clientAppInstallID,
            touchCapabilities: streamDependencies.touchPlatform?.capabilities
        )

        startedAt = .now
        connectTask = Task { await connect(with: options) }
    }

    private func networkQuality(for requested: StreamQuality) -> StreamQuality {
        switch streamDependencies.networkPath.isOnCellular {
        case true: requested.capped(at: preferences.cellularQuality)
        case false: requested
        }
    }

    private func connect(with options: StreamOptions) async {
        do {
            let streamConnection = try await streamService.connect(to: target, options: options)
            guard !Task.isCancelled, let renderer else { return }

            run(streamConnection, on: renderer)
        } catch XboxAccountError.signInRequired {
            onSignInRequired()

            fail(String(localized: "stream.failure.signInExpired", bundle: .module))
        } catch {
            guard !Task.isCancelled else { return }

            fail(error.localizedDescription)
        }
    }

    private func run(_ streamConnection: StreamConnection, on renderer: StreamRenderer) {
        self.streamConnection = streamConnection

        renderer.notifyFirstFrame { [weak self] in
            Task { @MainActor in self?.didPresentFirstFrame() }
        }

        updatesTask = Task { [weak self] in
            for await update in streamConnection.updates {
                self?.receive(update)
            }
        }

        systemDialogsViewModel.attach(streamConnection)

        wireInput(to: streamConnection)

        runTask = Task { await streamConnection.start(sink: renderer) }
    }

    private func didPresentFirstFrame() {
        guard !hasFirstFrame else { return }

        hasFirstFrame = true
        log.info(
            "Startup first frame on screen +\((ContinuousClock.now - self.startedAt).formatted(.units(allowed: [.milliseconds])), privacy: .public)"
        )
    }

    private func receive(_ update: StreamUpdate) {
        switch update {
        case .phase(let phase): enter(phase)
        case .statistics(let statistics): record(statistics)
        case .dialog(let request): systemDialogsViewModel.add(request)
        case .dialogDismissed(let id): systemDialogsViewModel.remove(id: id)
        case .vibration(let effect): play(effect)
        case .videoSize: break
        case .touchControls(let command): touchControlsViewModel?.apply(command)
        case .runningTitle(let title): loadTouchLayouts(for: title)
        }
    }

    private func loadTouchLayouts(for title: RunningTitle) {
        guard let touchControlsViewModel, title.isFocused else { return }

        let id = title.titleID
        let isNewlyFocused = !touchControlsViewModel.isFocused(onTitle: id)
        touchControlsViewModel.focus(onTitle: id)
        if isNewlyFocused { announceTouchBundle(touchControlsViewModel.titleBundleManifest) }
        guard needsTouchBundle(for: id) else { return }

        touchBundleAttempts[id, default: 0] += 1
        touchBundleTasks[id] = Task {
            await loadTouchBundle(for: id, into: touchControlsViewModel)
        }
    }

    private func needsTouchBundle(for titleID: String) -> Bool {
        let maximumAttempts = 3

        return !touchBundleTitles.contains(titleID) && touchBundleTasks[titleID] == nil
            && touchBundleAttempts[titleID, default: 0] < maximumAttempts
    }

    private func loadTouchBundle(
        for titleID: String,
        into touchControlsViewModel: TouchControlsViewModel
    ) async {
        defer { touchBundleTasks[titleID] = nil }

        do {
            let bundle = try await streamService.touchBundle(forTitle: titleID, on: target)
            guard !Task.isCancelled else { return }

            touchBundleTitles.insert(titleID)
            guard let bundle else { return }

            touchControlsViewModel.load(bundle, forTitle: titleID)
            if touchControlsViewModel.isFocused(onTitle: titleID) {
                announceTouchBundle(bundle.manifest)
            }
        } catch {
            log.error(
                "Touch layouts for \(titleID, privacy: .public) could not be loaded: \(error)"
            )
        }
    }

    private func announceTouchBundle(_ manifest: TouchBundleManifest?) {
        guard let manifest, let streamConnection else { return }

        Task {
            await streamConnection.announceTouchBundle(
                version: manifest.version,
                versionName: manifest.versionName ?? manifest.version
            )
        }
    }

    private func play(_ effect: VibrationEffect) {
        logFirstRumble(effect)

        guard controllerHub.isRoutingToGame, preferences.isRumbleEnabled else { return }

        controllerHub.playRumble(effect)
    }

    private func logFirstRumble(_ effect: VibrationEffect) {
        guard !hasLoggedFirstRumble else { return }

        hasLoggedFirstRumble = true
        log.info(
            "Host sent rumble for pad \(effect.gamepadIndex): \(effect.leftMotor) / \(effect.rightMotor), enabled \(self.preferences.isRumbleEnabled)"
        )
    }

    private func enter(_ phase: StreamPhase) {
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

        controllerHub.stopRumble()

        onEnd()
    }

    private func record(_ statistics: StreamStatistics) {
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

    private func wireInput(to streamConnection: StreamConnection) {
        controllerHub.gamepadRouter.setDestination { slot, state in
            streamConnection.setGamepad(slot, state: state)
        }
    }

    private func fail(_ message: String) {
        phase = .ended(.failed(message))
    }

    func stop(_ reason: StreamEndReason) async {
        onStop()

        controllerHub.gamepadRouter.setDestination(nil)
        controllerHub.stopRumble()

        connectTask?.cancel()
        runTask?.cancel()
        hideControlsTask?.cancel()
        settingsTask?.cancel()
        for task in touchBundleTasks.values { task.cancel() }

        if let streamConnection {
            await streamConnection.stop(reason: reason)
        }

        updatesTask?.cancel()

        renderer?.clear()

        if !hasEnded {
            phase = .ended(reason)
        }
    }

    public func tryAgain() {
        guard restartTask == nil else { return }

        restartTask = Task { await onRestart() }
    }

    public func revealControls() {
        areControlsRevealed = true

        hideControlsTask?.cancel()

        guard let delay = streamDependencies.overlays.controlsHideDelay else { return }

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
        releaseKeyboard()
    }

    public func closeMenu() {
        isMenuOpen = false
    }

    public func enterForeground() {
        isInForeground = true

        requestKeyframe()
    }

    public func enterBackground() {
        isInForeground = false
        releaseKeyboard()
    }

    public func openGuide() {
        guard let streamConnection else { return }

        Task { await streamConnection.pressGuide() }
    }

    public func openXboxButtonSettings() {
        controllerHub.xboxButton.openSettings()
    }

    public func requestKeyframe() {
        guard let streamConnection else { return }

        Task { await streamConnection.requestKeyframe() }
    }

    public func showNextPictureFit() {
        let fits = PictureFit.allCases
        guard let index = fits.firstIndex(of: preferences.pictureFit) else { return }

        preferences.pictureFit = fits[(index + 1) % fits.count]
    }

    @discardableResult
    public func handleKey(_ keyCode: UInt16, isDown: Bool) -> Bool {
        guard preferences.isKeyboardControllerEnabled, isStreaming else { return false }
        guard isAcceptingKeyboard else {
            releaseKeyboard()
            return false
        }

        let isHandled = keyboardGamepad.setKey(keyCode, isDown: isDown)

        if isHandled {
            controllerHub.gamepadRouter.setKeyboard(keyboardGamepad.state)
        }

        return isHandled
    }

    private var isAcceptingKeyboard: Bool {
        !isMenuOpen && systemDialogsViewModel.dialogQueue.isEmpty
    }

    public func releaseKeyboard() {
        keyboardGamepad.releaseAll()
        controllerHub.gamepadRouter.setKeyboard(keyboardGamepad.state)
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
