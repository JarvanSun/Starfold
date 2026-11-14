//
//  StreamPlatform.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public struct StreamPlatform {
    let controllerRouting: ControllerRouting
    let pictureCapabilities: PictureCapabilities
    let overlays: StreamOverlays
    let touchPlatform: TouchPlatform?

    public init(
        controllerRouting: ControllerRouting,
        pictureCapabilities: PictureCapabilities,
        overlays: StreamOverlays,
        touchPlatform: TouchPlatform?
    ) {
        self.controllerRouting = controllerRouting
        self.pictureCapabilities = pictureCapabilities
        self.overlays = overlays
        self.touchPlatform = touchPlatform
    }
}
