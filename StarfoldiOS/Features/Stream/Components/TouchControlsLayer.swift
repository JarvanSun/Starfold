//
//  TouchControlsLayer.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchControlsLayer: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dimensions) private var dimensions

    let touchControlsViewModel: TouchControlsViewModel
    let isActive: Bool

    let onConnect: () -> Void

    var body: some View {
        GeometryReader { proxy in
            TouchControlsOverlay(
                plan: touchControlsViewModel.plan(
                    for: dimensions.touchMetrics(forVerticalSizeClass: verticalSizeClass),
                    in: TouchOrientation(size: proxy.size)
                ),
                mode: mode,
                onConnect: onConnect
            )
        }
    }

    private var mode: TouchControlsMode {
        isActive ? .playing(isHapticsEnabled: touchControlsViewModel.isHapticsEnabled) : .hidden
    }
}
