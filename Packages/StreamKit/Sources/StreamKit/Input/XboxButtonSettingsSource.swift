//
//  XboxButtonSettingsSource.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController

struct XboxButtonSettingsSource {
    let readOwner: @MainActor () throws -> XboxButtonOwner
    let openSettings: @MainActor () throws -> Void
    let observeChanges:
        @MainActor (_ onChange: @escaping @MainActor () -> Void) -> Task<Void, Never>
}

extension XboxButtonSettingsSource {
    @MainActor
    init?() {
        #if os(tvOS)
        return nil
        #else
        guard #available(macOS 27.0, iOS 27.0, visionOS 27.0, *) else { return nil }

        let manager = GCControllerHomeButtonSettingsManager()

        self.init(
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
