//
//  Preferences.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Observation
import StreamKit
import XboxKit

@Observable
public final class Preferences {
    var consoleQuality: QualityChoice {
        didSet { defaults.set(consoleQuality.storageValue, for: .consoleQuality) }
    }
    var cloudQuality: QualityChoice {
        didSet { defaults.set(cloudQuality.storageValue, for: .cloudQuality) }
    }
    var cellularQuality: QualityChoice {
        didSet { defaults.set(cellularQuality.storageValue, for: .cellularQuality) }
    }
    var maxBitrateMbps: Int {
        didSet { defaults.set(maxBitrateMbps, for: .maxBitrate) }
    }
    var pacingMode: PacingMode {
        didSet { defaults.set(pacingMode.rawValue, for: .pacingMode) }
    }
    var isUpscalingEnabled: Bool {
        didSet { defaults.set(isUpscalingEnabled, for: .upscaling) }
    }
    var sharpening: Double {
        didSet { defaults.set(sharpening, for: .sharpening) }
    }
    var pictureFit: PictureFit {
        didSet { defaults.set(pictureFit.rawValue, for: .pictureFit) }
    }
    var isHDRToneMappingEnabled: Bool {
        didSet { defaults.set(isHDRToneMappingEnabled, for: .hdrToneMapping) }
    }
    var shouldShowStatistics: Bool {
        didSet { defaults.set(shouldShowStatistics, for: .showStatistics) }
    }
    var gameLanguage: String {
        didSet { defaults.set(gameLanguage, for: .gameLanguage) }
    }
    var isKeyboardControllerEnabled: Bool {
        didSet { defaults.set(isKeyboardControllerEnabled, for: .keyboardAsController) }
    }
    var isRumbleEnabled: Bool {
        didSet { defaults.set(isRumbleEnabled, for: .rumble) }
    }
    var isTouchHapticsEnabled: Bool {
        didSet { defaults.set(isTouchHapticsEnabled, for: .touchHaptics) }
    }
    var soundStage: SoundStage {
        didSet { defaults.set(soundStage.rawValue, for: .soundStage) }
    }
    var palette: PaletteID {
        didSet { defaults.set(palette.rawValue, for: .palette) }
    }
    var shouldShowInMenuBar: Bool {
        didSet { defaults.set(shouldShowInMenuBar, for: .showInMenuBar) }
    }
    var librarySort: GameSort {
        didSet { defaults.set(librarySort.rawValue, for: .librarySort) }
    }

    private let defaults: UserDefaults

    var lastAccountID: String? {
        get { defaults.string(for: .lastAccountID) }
        set { defaults.set(newValue, for: .lastAccountID) }
    }

    var effectiveGameLanguage: String {
        switch gameLanguage.isEmpty {
        case true: systemGameLanguage
        case false: gameLanguage
        }
    }

    private var systemGameLanguage: String {
        let locale = Locale.current
        let language = locale.language.languageCode?.identifier ?? "en"
        let region = locale.region?.identifier ?? "US"
        return "\(language)-\(region)"
    }

    var clientAppInstallID: UUID {
        switch defaults.string(for: .installID).flatMap(UUID.init(uuidString:)) {
        case let storedID?: storedID
        case nil: makeInstallID()
        }
    }

    private func makeInstallID() -> UUID {
        let id = UUID()
        defaults.set(id.uuidString, for: .installID)
        return id
    }

    public init(defaults: UserDefaults) {
        let factory = FactorySettings()
        self.defaults = defaults
        consoleQuality = .init(storageValue: defaults.string(for: .consoleQuality))
        cloudQuality = .init(storageValue: defaults.string(for: .cloudQuality))
        cellularQuality =
            defaults.string(for: .cellularQuality).map(QualityChoice.init(storageValue:))
            ?? factory.cellularQuality
        maxBitrateMbps = defaults.object(for: .maxBitrate) ?? factory.maxBitrateMbps
        isUpscalingEnabled = defaults.object(for: .upscaling) ?? factory.isUpscalingEnabled
        sharpening = defaults.object(for: .sharpening) ?? factory.sharpening
        shouldShowStatistics = defaults.bool(for: .showStatistics)
        gameLanguage = defaults.string(for: .gameLanguage) ?? ""
        isKeyboardControllerEnabled =
            defaults.object(for: .keyboardAsController) ?? factory.isKeyboardControllerEnabled
        isRumbleEnabled = defaults.object(for: .rumble) ?? factory.isRumbleEnabled
        isTouchHapticsEnabled = defaults.object(for: .touchHaptics) ?? factory.isTouchHapticsEnabled
        shouldShowInMenuBar = defaults.object(for: .showInMenuBar) ?? factory.shouldShowInMenuBar
        pacingMode = .init(storedValue: defaults.string(for: .pacingMode))
        soundStage =
            defaults.string(for: .soundStage).flatMap(SoundStage.init(rawValue:))
            ?? factory.soundStage
        palette = .init(storedValue: defaults.string(for: .palette))
        pictureFit = .init(storedValue: defaults.string(for: .pictureFit))
        isHDRToneMappingEnabled = defaults.bool(for: .hdrToneMapping)
        librarySort =
            defaults.string(for: .librarySort).flatMap(GameSort.init(rawValue:))
            ?? factory.librarySort
    }

    func touchLayoutAdjustments(for orientation: TouchOrientation) -> TouchLayoutAdjustments {
        let stored = defaults.data(forKey: touchLayoutKey(for: orientation))
        return stored.flatMap { try? JSONDecoder().decode(TouchLayoutAdjustments.self, from: $0) }
            ?? .init()
    }

    func setTouchLayoutAdjustments(
        _ adjustments: TouchLayoutAdjustments,
        for orientation: TouchOrientation
    ) {
        let encoded = try? JSONEncoder().encode(adjustments)
        defaults.set(encoded, forKey: touchLayoutKey(for: orientation))
    }

    private func touchLayoutKey(for orientation: TouchOrientation) -> String {
        let touchLayoutKeyPrefix = "touchLayout."

        return touchLayoutKeyPrefix + orientation.rawValue
    }

    public func favorites(for xuid: String) -> FavoritesStore {
        .init(defaults: defaults, key: favoritesKey(for: xuid))
    }

    private func favoritesKey(for xuid: String) -> String {
        let favoritesKeyPrefix = "favorites."

        return favoritesKeyPrefix + xuid
    }
}

private enum PreferenceKey: String {
    case lastAccountID
    case consoleQuality
    case cloudQuality
    case cellularQuality
    case maxBitrate
    case upscaling
    case sharpening
    case showStatistics
    case gameLanguage
    case keyboardAsController
    case rumble
    case touchHaptics
    case showInMenuBar
    case pacingMode
    case soundStage
    case palette
    case pictureFit
    case hdrToneMapping
    case librarySort
    case installID
}

private struct FactorySettings {
    var cellularQuality: QualityChoice { .fixed(.standard) }

    var maxBitrateMbps: Int { 0 }

    var isUpscalingEnabled: Bool { true }

    var sharpening: Double { 0.3 }

    var isKeyboardControllerEnabled: Bool { true }

    var isRumbleEnabled: Bool { true }

    var isTouchHapticsEnabled: Bool { true }

    var shouldShowInMenuBar: Bool { true }

    var soundStage: SoundStage { .window }

    var librarySort: GameSort { .name }
}

// MARK: - UserDefaults

private extension UserDefaults {
    func string(for key: PreferenceKey) -> String? {
        string(forKey: key.rawValue)
    }

    func bool(for key: PreferenceKey) -> Bool {
        bool(forKey: key.rawValue)
    }

    func object<Value>(for key: PreferenceKey) -> Value? {
        object(forKey: key.rawValue) as? Value
    }

    func set(_ value: Any?, for key: PreferenceKey) {
        set(value, forKey: key.rawValue)
    }
}
