//
//  StreamDependencies.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public struct StreamDependencies {
    let preferences: Preferences
    let controllerHub: ControllerHub
    let streamPlatform: StreamPlatform
    let networkPath: NetworkPathReading

    var pictureCapabilities: PictureCapabilities {
        streamPlatform.pictureCapabilities
    }

    var overlays: StreamOverlays {
        streamPlatform.overlays
    }

    var touchPlatform: TouchPlatform? {
        streamPlatform.touchPlatform
    }

    public init(
        preferences: Preferences,
        controllerHub: ControllerHub,
        streamPlatform: StreamPlatform,
        networkPath: NetworkPathReading
    ) {
        self.preferences = preferences
        self.controllerHub = controllerHub
        self.streamPlatform = streamPlatform
        self.networkPath = networkPath
    }
}
