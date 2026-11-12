//
//  StreamDependenciesDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

@testable import StarfoldShared

extension StreamDependencies {
    static func dummy(preferences: Preferences) -> StreamDependencies {
        .init(
            preferences: preferences,
            controllers: ControllerHub(routing: .direct),
            picture: .init(
                canFit: true,
                canEnhance: false,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: nil
            ),
            overlays: .init(
                statisticsRows: [.resolution, .lowered, .frameRate],
                controlsHideDelay: .milliseconds(20)
            )
        )
    }
}
