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
    let picture: PictureCapabilities
    let overlays: StreamOverlays

    public init(
        preferences: Preferences,
        controllers: ControllerHub,
        picture: PictureCapabilities,
        overlays: StreamOverlays
    ) {
        self.preferences = preferences
        self.controllers = controllers
        self.picture = picture
        self.overlays = overlays
    }
}
