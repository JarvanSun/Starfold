//
//  StreamDependencies.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public struct StreamDependencies {
    let preferences: Preferences
    let controllers: ControllerHub
    let platform: StreamPlatform
    let network: NetworkPathReading

    var picture: PictureCapabilities {
        platform.picture
    }

    var overlays: StreamOverlays {
        platform.overlays
    }

    var touch: TouchPlatform? {
        platform.touch
    }

    public init(
        preferences: Preferences,
        controllers: ControllerHub,
        platform: StreamPlatform,
        network: NetworkPathReading
    ) {
        self.preferences = preferences
        self.controllers = controllers
        self.platform = platform
        self.network = network
    }
}
