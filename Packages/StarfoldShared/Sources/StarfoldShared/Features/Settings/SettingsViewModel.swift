//
//  SettingsViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Observation
import StreamKit
import XboxKit

@Observable
public final class SettingsViewModel {
    private let preferences: Preferences
    private let controllers: ControllerHub
    private let picture: PictureCapabilities

    weak var session: SessionControlling?

    public var consoleQuality: QualityChoice {
        get { preferences.consoleQuality }
        set { preferences.consoleQuality = newValue }
    }

    public var cloudQuality: QualityChoice {
        get { preferences.cloudQuality }
        set { preferences.cloudQuality = newValue }
    }

    public var maxBitrateMbps: Int {
        get { preferences.maxBitrateMbps }
        set { preferences.maxBitrateMbps = newValue }
    }

    public var gameLanguage: String {
        get { preferences.gameLanguage }
        set { preferences.gameLanguage = newValue }
    }

    public var isUpscalingEnabled: Bool {
        get { preferences.isUpscalingEnabled }
        set { preferences.isUpscalingEnabled = newValue }
    }

    public var sharpening: Double {
        get { preferences.sharpening }
        set { preferences.sharpening = newValue }
    }

    public var isHDRToneMappingEnabled: Bool {
        get { preferences.isHDRToneMappingEnabled }
        set { preferences.isHDRToneMappingEnabled = newValue }
    }

    public var pictureFit: PictureFit {
        get { preferences.pictureFit }
        set { preferences.pictureFit = newValue }
    }

    public var pacingMode: PacingMode {
        get { preferences.pacingMode }
        set { preferences.pacingMode = newValue }
    }

    public var shouldShowStatistics: Bool {
        get { preferences.shouldShowStatistics }
        set { preferences.shouldShowStatistics = newValue }
    }

    public var soundStage: SoundStage {
        get { preferences.soundStage }
        set { preferences.soundStage = newValue }
    }

    public var isRumbleEnabled: Bool {
        get { preferences.isRumbleEnabled }
        set { preferences.isRumbleEnabled = newValue }
    }

    public var isKeyboardControllerEnabled: Bool {
        get { preferences.isKeyboardControllerEnabled }
        set { preferences.isKeyboardControllerEnabled = newValue }
    }

    public var palette: PaletteID {
        get { preferences.palette }
        set { preferences.palette = newValue }
    }

    public var shouldShowInMenuBar: Bool {
        get { preferences.shouldShowInMenuBar }
        set { preferences.shouldShowInMenuBar = newValue }
    }

    public var qualityChoices: [QualityChoice] {
        [.automatic, .fixed(.standard), .fixed(.high), .fixed(.highest)]
    }

    public var bitrateChoices: [Int] {
        [automaticBitrate, 10, 20, 30, 40, 60, 80]
    }

    public var gameLanguages: [String] {
        [
            systemGameLanguage,
            "en-US",
            "en-GB",
            "zh-CN",
            "zh-TW",
            "ja-JP",
            "ko-KR",
            "de-DE",
            "fr-FR",
            "es-ES",
            "it-IT",
            "pt-BR",
            "ru-RU",
        ]
    }

    public var pictureFits: [PictureFit] {
        PictureFit.allCases
    }

    public var pacingModes: [PacingMode] {
        PacingMode.allCases
    }

    public var soundStages: [SoundStage] {
        SoundStage.allCases
    }

    public var canToneMapHDR: Bool {
        picture.isHDRDisplayAvailable?() ?? false
    }

    public var connectedControllers: [ConnectedController] {
        controllers.connected
    }

    public var isControllerMissing: Bool {
        controllers.connected.isEmpty
    }

    public var keyBindings: [KeyBinding] {
        KeyboardGamepad().bindings
    }

    public var needsStreamRestart: Bool {
        session?.needsStreamRestartForSettings ?? false
    }

    public var accountChoices: [AccountChoice] {
        guard let session else { return [] }

        return session.accounts.map {
            .init(id: $0.id, gamertag: $0.gamertag, isActive: $0.id == session.activeAccountID)
        }
    }

    public var signOutSubject: String {
        session?.signedInGamertag ?? AppInfo().displayName
    }

    var effectiveGameLanguage: String {
        preferences.effectiveGameLanguage
    }

    var canEnhancePicture: Bool {
        picture.canEnhance
    }

    var canChoosePictureFit: Bool {
        picture.canFit
    }

    public init(
        preferences: Preferences,
        controllers: ControllerHub,
        picture: PictureCapabilities
    ) {
        self.preferences = preferences
        self.controllers = controllers
        self.picture = picture
    }

    public func restartStream() async {
        await session?.restartStream()
    }

    public func testRumble(on controller: ConnectedController) {
        controllers.testRumble(slot: controller.slot)
    }

    public func switchAccount(to choice: AccountChoice) async {
        await session?.switchAccount(to: choice.id)
    }

    public func signOut() {
        session?.signOut()
    }

    public func title(ofBitrate bitrate: Int) -> LocalizedStringResource {
        switch isAutomatic(bitrate: bitrate) {
        case true: .init("settings.bitrate.automatic", bundle: .module)
        case false: .init("settings.bitrate.option \(bitrate)", bundle: .module)
        }
    }

    public func name(ofGameLanguage code: String) -> String {
        switch isSystem(gameLanguage: code) {
        case true: String(localized: "settings.gameLanguage.system", bundle: .module)
        case false: Locale.current.localizedString(forIdentifier: code) ?? code
        }
    }

    public func playerNumber(of controller: ConnectedController) -> Int {
        Int(controller.slot) + 1
    }

    public func batteryLevel(of controller: ConnectedController) -> Double? {
        guard let battery = controller.batteryLevel, battery > 0 else { return nil }

        return Double(battery)
    }

    func isAutomatic(bitrate: Int) -> Bool {
        bitrate == automaticBitrate
    }

    func isSystem(gameLanguage code: String) -> Bool {
        code == systemGameLanguage
    }
}

// MARK: - Private

private extension SettingsViewModel {
    var automaticBitrate: Int {
        0
    }

    var systemGameLanguage: String {
        ""
    }
}
