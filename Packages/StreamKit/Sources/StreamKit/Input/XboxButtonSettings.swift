//
//  XboxButtonSettings.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController
import Observation
import os

@MainActor
@Observable
public final class XboxButtonSettings {
    struct Source {
        let readOwner: @MainActor () throws -> XboxButtonOwner
        let openSettings: @MainActor () throws -> Void
        let observeChanges:
            @MainActor (_ onChange: @escaping @MainActor () -> Void) -> Task<Void, Never>
    }

    public private(set) var owner: XboxButtonOwner = .unknown

    @ObservationIgnored private let source: Source?
    @ObservationIgnored private var changes: Task<Void, Never>?
    @ObservationIgnored private var isControllerConnected = false
    @ObservationIgnored private let log = Logger(category: .controllers)

    public var canOpenSettings: Bool {
        source != nil
    }

    public convenience init() {
        self.init(source: .system)
    }

    init(source: Source?) {
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

extension XboxButtonSettings.Source {
    @MainActor
    static var system: Self? {
        #if os(tvOS)
        nil
        #else
        guard #available(macOS 27.0, iOS 27.0, visionOS 27.0, *) else { return nil }

        let manager = GCControllerHomeButtonSettingsManager()

        return Self(
            readOwner: {
                XboxButtonOwner(inAppAction: try manager.controllerHomeButtonInAppAction.action)
            },
            openSettings: {
                try manager.openControllerHomeButtonSettings(for: .customizeInAppAction)
            },
            observeChanges: { onChange in
                Task {
                    for await _ in manager.settingsUpdates {
                        onChange()
                    }
                }
            }
        )
        #endif
    }
}
