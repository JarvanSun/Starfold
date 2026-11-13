//
//  StreamPlatform.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public struct StreamPlatform {
    let controllerRouting: ControllerRouting
    let picture: PictureCapabilities
    let overlays: StreamOverlays
    let touch: TouchCapabilities?

    public init(
        controllerRouting: ControllerRouting,
        picture: PictureCapabilities,
        overlays: StreamOverlays,
        touch: TouchCapabilities?
    ) {
        self.controllerRouting = controllerRouting
        self.picture = picture
        self.overlays = overlays
        self.touch = touch
    }
}
