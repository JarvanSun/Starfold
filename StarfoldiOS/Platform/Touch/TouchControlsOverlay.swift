//
//  TouchControlsOverlay.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchControlsOverlay: UIViewRepresentable {
    @Environment(\.dimensions) private var dimensions

    let plan: TouchControlPlan
    let isActive: Bool
    let isInteractive: Bool
    let isHapticsEnabled: Bool

    let onConnect: () -> Void

    func makeUIView(context: Context) -> TouchControllerView {
        let view = TouchControllerView()
        view.show(plan)
        onConnect()
        return view
    }

    func updateUIView(_ view: TouchControllerView, context: Context) {
        view.show(plan)
        view.setActive(isActive, isInteractive: isInteractive)
        view.isHapticsEnabled = isHapticsEnabled
        view.stickPassThroughZone = dimensions.streamMenuHandleZone
    }

    static func dismantleUIView(_ view: TouchControllerView, coordinator: ()) {
        view.disconnect()
    }
}
