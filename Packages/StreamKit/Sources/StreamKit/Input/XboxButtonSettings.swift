//
//  XboxButtonSettings.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Observation
import os

@MainActor
@Observable
public final class XboxButtonSettings {
    public private(set) var owner: XboxButtonOwner = .unknown

    private let settingsSource: XboxButtonSettingsSource?
    private let log = Logger(category: .controllers)

    @ObservationIgnored private var changeObservation: Task<Void, Never>?
    @ObservationIgnored private var isControllerConnected = false

    public convenience init() {
        self.init(settingsSource: XboxButtonSettingsSource())
    }

    init(settingsSource: XboxButtonSettingsSource?) {
        self.settingsSource = settingsSource
        changeObservation = settingsSource?.observeChanges { [weak self] in self?.refresh() }
    }

    isolated deinit {
        changeObservation?.cancel()
    }

    public func openSettings() {
        do {
            try settingsSource?.openSettings()
        } catch {
            log.error("Couldn't open the Xbox button settings: \(error)")
        }
    }

    func setControllerConnected(_ isConnected: Bool) {
        isControllerConnected = isConnected
        refresh()
    }

    private func refresh() {
        guard isControllerConnected, let settingsSource else {
            owner = .unknown
            return
        }

        do {
            owner = try settingsSource.readOwner()
        } catch {
            log.error("Couldn't read the Xbox button setting: \(error)")
            owner = .unknown
        }
    }
}
