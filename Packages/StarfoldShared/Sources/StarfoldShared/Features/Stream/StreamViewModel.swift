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
    public var dialogText = "" {
        didSet { limitDialogText() }
    }

    public var onStop: () -> Void = {}
    public var onEnd: () -> Void = {}
    var onSignInRequired: () -> Void = {}
    var onRestart: () async -> Void = {}

    public private(set) var phase: StreamPhase = .provisioning
    public private(set) var dialogs: [SystemDialogRequest] = []
    public private(set) var hasFirstFrame = false
    public private(set) var areControlsRevealed = true

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
    private var keyboard = KeyboardGamepad()
    private var draftedDialogID: String?
    private var hasLoggedFirstRumble = false
    private var statisticsTicks = 0
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

    public var isShowingControls: Bool {
        isStreaming && areControlsRevealed
    }

    public var canOpenMenu: Bool {
        isStreaming && dialogs.isEmpty
    }

    public var isPlayable: Bool {
        !isWaitingForPicture && dialogs.isEmpty && !controllers.connected.isEmpty
    }

    public var needsController: Bool {
        isStreaming && controllers.connected.isEmpty
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

    public var presentedDialog: SystemDialogRequest? {
        dialogs.first
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

        applySettings()

        observeSettings()
    }

    public func start() {
        guard renderer != nil else {
            fail(String(localized: "stream.failure.metalUnavailable", bundle: .module))

            return
        }

        let settings = StreamSettings(target: target, preferences: preferences)
        startedSettings = settings

        let quality = qualityOverride ?? settings.choice.requestedQuality
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

    func stop() async {
        onStop()

        controllers.router.setDestination(nil)
        controllers.stopRumble()

        connectTask?.cancel()
        runTask?.cancel()
        hideControlsTask?.cancel()

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

    public func openGuide() {
        guard let connection else { return }

        Task { await connection.pressGuide() }
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

    public func answer(_ dialog: SystemDialogRequest, buttonIndex: Int) {
        remove(dialogID: dialog.id)

        guard let connection else { return }

        Task { await connection.answerDialog(id: dialog.id, buttonIndex: buttonIndex) }
    }

    public func submitText(for dialog: SystemDialogRequest) {
        answerKeyboard(dialog, text: dialogText)
    }

    public func cancel(_ dialog: SystemDialogRequest) {
        switch dialog.kind {
        case .message(_, _, _, _, let cancelIndex?): answer(dialog, buttonIndex: cancelIndex)
        case .message(_, _, _, _, nil): break
        case .keyboard: answerKeyboard(dialog, text: nil)
        }
    }

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

    public func buttons(of dialog: SystemDialogRequest) -> [DialogButton] {
        switch dialog.kind {
        case .message(_, _, let titles, _, _) where titles.isEmpty: [acknowledgeButton]
        case .message(_, _, let titles, let defaultIndex, let cancelIndex):
            titles.enumerated().map { index, title in
                .init(
                    index: index,
                    title: title,
                    role: role(
                        ofButtonAt: index,
                        defaultIndex: defaultIndex,
                        cancelIndex: cancelIndex
                    )
                )
            }
        case .keyboard: []
        }
    }

    public func textFieldTitle(of dialog: SystemDialogRequest) -> String {
        switch dialog.kind {
        case .keyboard(let title, _, _, _) where !title.isEmpty: title
        case .keyboard, .message:
            String(localized: "stream.dialog.textFieldTitle", bundle: .module)
        }
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

// MARK: - Private

private extension StreamViewModel {
    var preferences: Preferences {
        dependencies.preferences
    }

    var controllers: ControllerHub {
        dependencies.controllers
    }

    var pacingLogInterval: Int {
        5
    }

    var shortestQueueEstimate: Duration {
        .seconds(60)
    }

    var shownFit: PictureFit {
        dependencies.picture.canFit ? preferences.pictureFit : .fit
    }

    var videoGravity: AVLayerVideoGravity {
        switch shownFit {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .scale: .resize
        }
    }

    var canChooseDynamicRange: Bool {
        dependencies.picture.isHDRDisplayAvailable != nil
    }

    var isToneMappingHDR: Bool {
        guard let isHDRDisplayAvailable = dependencies.picture.isHDRDisplayAvailable else {
            return false
        }

        return preferences.isHDRToneMappingEnabled && isHDRDisplayAvailable()
    }

    var acknowledgeButton: DialogButton {
        .init(
            index: 0,
            title: String(localized: "stream.dialog.ok", bundle: .module),
            role: .primary
        )
    }

    func applySettings() {
        applyPacing()

        applyEnhancements()

        applySoundStage()
    }

    func applyPacing() {
        renderer?.systemVideo.setPacing(preferences.pacingMode)
    }

    func applyEnhancements() {
        guard let renderer else { return }

        renderer.systemVideo.layer.videoGravity = videoGravity

        let isToneMapping = isToneMappingHDR

        if canChooseDynamicRange {
            renderer.systemVideo.layer.preferredDynamicRange = isToneMapping ? .high : .standard
        }

        if dependencies.picture.canEnhance {
            renderer.setEnhancements(
                .init(
                    isUpscaling: preferences.isUpscalingEnabled,
                    sharpening: Float(preferences.sharpening),
                    fit: preferences.pictureFit,
                    isToneMappingHDR: isToneMapping
                )
            )
        }
    }

    func applySoundStage() {
        service.setDirectStereo(preferences.soundStage == .direct)
    }

    func observeSettings() {
        withObservationTracking {
            readAppliedSettings()
        } onChange: { [weak self] in
            Task { @MainActor in self?.applyChangedSettings() }
        }
    }

    func readAppliedSettings() {
        _ = preferences.pacingMode
        _ = preferences.pictureFit
        _ = preferences.isUpscalingEnabled
        _ = preferences.sharpening
        _ = preferences.isHDRToneMappingEnabled
        _ = preferences.soundStage
    }

    func applyChangedSettings() {
        guard !hasEnded else { return }

        applySettings()

        observeSettings()
    }

    func fail(_ message: String) {
        phase = .ended(.failed(message))
    }

    func connect(with options: StreamOptions) async {
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

    func run(_ connection: StreamConnection, on renderer: StreamRenderer) {
        self.connection = connection

        renderer.notifyFirstFrame { [weak self] in
            Task { @MainActor in self?.didPresentFirstFrame() }
        }

        updatesTask = Task { [weak self] in
            for await update in connection.updates {
                self?.apply(update)
            }
        }

        wireInput(to: connection)

        runTask = Task { await connection.start(sink: renderer) }
    }

    func didPresentFirstFrame() {
        guard !hasFirstFrame else { return }

        hasFirstFrame = true
        log.info(
            "Startup first frame on screen +\((ContinuousClock.now - self.startedAt).formatted(.units(allowed: [.milliseconds])), privacy: .public)"
        )
    }

    func apply(_ update: StreamUpdate) {
        switch update {
        case .phase(let phase): apply(phase)
        case .statistics(let statistics): apply(statistics)
        case .dialog(let request): add(request)
        case .dialogDismissed(let id): remove(dialogID: id)
        case .vibration(let effect): play(effect)
        case .videoSize: break
        }
    }

    func apply(_ phase: StreamPhase) {
        self.phase = phase

        switch phase {
        case .streaming: revealControls()
        case .ended: finishAfterEnd()
        case .provisioning, .queued, .connecting: break
        }
    }

    func finishAfterEnd() {
        hideControlsTask?.cancel()

        controllers.stopRumble()

        onEnd()
    }

    func hideControls(after delay: Duration) async {
        try? await Task.sleep(for: delay)

        guard !Task.isCancelled else { return }

        areControlsRevealed = false
    }

    func queueEstimate(_ wait: Duration) -> String {
        max(wait, shortestQueueEstimate).formatted(.units(allowed: [.minutes], width: .wide))
    }

    func apply(_ statistics: StreamStatistics) {
        var statistics = statistics
        statistics.displayMs = renderer?.displayLatencyMs
        statistics.upscaledTo = renderer?.upscaledTo
        statistics.isToneMapped = renderer?.isToneMapping ?? false
        self.statistics = statistics

        logPacing()

        noteResolution(statistics.resolution)
    }

    func logPacing() {
        statisticsTicks += 1

        guard statisticsTicks.isMultiple(of: pacingLogInterval), let renderer else { return }

        let pacing = renderer.systemVideo.takeCounters()
        log.info(
            "Pacing 5s: \(String(describing: self.preferences.pacingMode), privacy: .public) \(Int(pacing.pacingDelayMs.rounded())) ms, late \(pacing.lateFrames) frames"
        )
    }

    func noteResolution(_ received: CGSize?) {
        guard let received, let quality else { return }

        isResolutionLowered = AdaptiveQuality(target: target)
            .isLoweredByHost(received: received, requested: quality)
    }

    func add(_ dialog: SystemDialogRequest) {
        dialogs.append(dialog)

        draftTextForPresentedDialog()
    }

    func remove(dialogID: String) {
        dialogs.removeAll { $0.id == dialogID }

        draftTextForPresentedDialog()
    }

    func draftTextForPresentedDialog() {
        guard draftedDialogID != presentedDialog?.id else { return }

        draftedDialogID = presentedDialog?.id
        dialogText = presentedDialog.map(defaultText(of:)) ?? ""
    }

    func defaultText(of dialog: SystemDialogRequest) -> String {
        switch dialog.kind {
        case .keyboard(_, _, let defaultText, _): defaultText
        case .message: ""
        }
    }

    func limitDialogText() {
        guard
            case .keyboard(_, _, _, let maxLength?) = presentedDialog?.kind,
            dialogText.count > maxLength
        else {
            return
        }

        dialogText = String(dialogText.prefix(maxLength))
    }

    func answerKeyboard(_ dialog: SystemDialogRequest, text: String?) {
        remove(dialogID: dialog.id)

        guard let connection else { return }

        Task { await connection.answerKeyboard(id: dialog.id, text: text) }
    }

    func role(ofButtonAt index: Int, defaultIndex: Int, cancelIndex: Int?) -> DialogButtonRole {
        switch (index == defaultIndex, index == cancelIndex) {
        case (true, _): .primary
        case (false, true): .cancel
        case (false, false): .plain
        }
    }

    func play(_ effect: VibrationEffect) {
        logFirstRumble(effect)

        guard controllers.isRoutingToGame, preferences.isRumbleEnabled else { return }

        controllers.playRumble(effect)
    }

    func logFirstRumble(_ effect: VibrationEffect) {
        guard !hasLoggedFirstRumble else { return }

        hasLoggedFirstRumble = true
        log.info(
            "Host sent rumble for pad \(effect.gamepadIndex): \(effect.leftMotor) / \(effect.rightMotor), enabled \(self.preferences.isRumbleEnabled)"
        )
    }

    func wireInput(to connection: StreamConnection) {
        controllers.router.setDestination { slot, state in
            connection.setGamepad(slot, state: state)
        }
    }
}
