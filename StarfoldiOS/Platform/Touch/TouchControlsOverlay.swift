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
    let mode: TouchControlsMode

    var onConnect: () -> Void = {}

    func makeUIView(context: Context) -> TouchControllerView {
        let view = TouchControllerView()
        view.show(plan)
        onConnect()
        return view
    }

    func updateUIView(_ view: TouchControllerView, context: Context) {
        view.show(plan)
        view.apply(mode)
        view.stickPassThroughZone = dimensions.streamMenuHandleZone
    }

    static func dismantleUIView(_ view: TouchControllerView, coordinator: ()) {
        view.disconnect()
    }
}
