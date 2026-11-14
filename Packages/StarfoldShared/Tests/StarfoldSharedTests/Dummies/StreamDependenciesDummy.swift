//
//  StreamDependenciesDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

@testable import StarfoldShared

extension StreamDependencies {
    static func dummy(
        preferences: Preferences,
        touch: TouchPlatform? = nil,
        network: NetworkPathStub = .init()
    ) -> StreamDependencies {
        .init(
            preferences: preferences,
            controllers: ControllerHub(routing: .direct),
            platform: .init(
                controllerRouting: .direct,
                picture: .init(
                    canFit: true,
                    canEnhance: false,
                    shouldKeepLastFrame: false,
                    isHDRDisplayAvailable: nil
                ),
                overlays: .init(
                    statisticsRows: [.resolution, .lowered, .frameRate],
                    controlsHideDelay: .milliseconds(20)
                ),
                touch: touch
            ),
            network: network
        )
    }
}
