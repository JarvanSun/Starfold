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

    private let source: XboxButtonSettingsSource?
    private let log = Logger(category: .controllers)

    @ObservationIgnored private var changes: Task<Void, Never>?
    @ObservationIgnored private var isControllerConnected = false

    public convenience init() {
        self.init(source: XboxButtonSettingsSource())
    }

    init(source: XboxButtonSettingsSource?) {
        self.source = source
        changes = source?.observeChanges { [weak self] in self?.refresh() }
    }

    isolated deinit {
        changes?.cancel()
    }

    public func openSettings() {
        do {
            try source?.openSettings()
        } catch {
            log.error("Couldn't open the Xbox button settings: \(error)")
        }
    }

    func setControllerConnected(_ isConnected: Bool) {
        isControllerConnected = isConnected
        refresh()
    }

    private func refresh() {
        guard isControllerConnected, let source else {
            owner = .unknown
            return
        }

        do {
            owner = try source.readOwner()
        } catch {
            log.error("Couldn't read the Xbox button setting: \(error)")
            owner = .unknown
        }
    }
}
